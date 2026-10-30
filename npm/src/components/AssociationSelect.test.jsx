import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { AssociationSelect } from "./AssociationSelect";

const initial = ["Existing", "9007199254740993"];
const next = ["Next result", "9007199254740994"];
const response = (items) => ({
  ok: true,
  json: async () => ({ resourceOptions: items })
});
const props = {
  multiple: true,
  value: [initial[1]],
  label: "Publishers",
  input: { name: "property[publisher_ids][]", id: "publishers" },
  options: {
    resourceOptions: [initial],
    optionsUrl: "/admin/properties/example/edit.json?association=publishers"
  }
};

describe("AssociationSelect", () => {
  beforeEach(() => {
    vi.stubGlobal(
      "ResizeObserver",
      class {
        observe() {}
        unobserve() {}
        disconnect() {}
      }
    );
    HTMLElement.prototype.scrollIntoView = vi.fn();
  });
  afterEach(() => {
    vi.useRealTimers();
    vi.unstubAllGlobals();
  });

  it("keeps previous results in place and disables them until the new search completes", async () => {
    let resolveSearch;
    const fetch = vi
      .fn()
      .mockResolvedValueOnce(response([next]))
      .mockImplementationOnce(
        () =>
          new Promise((resolve) => {
            resolveSearch = resolve;
          })
      );
    vi.stubGlobal("fetch", fetch);
    const { container } = render(<AssociationSelect {...props} />);
    fireEvent.click(screen.getByRole("combobox"));
    const previousRow = await screen.findByRole("option", { name: "Next result" });
    const search = screen.getByRole("combobox", { name: "Search Publishers" });
    fireEvent.change(search, { target: { value: "Updated" } });

    expect(screen.getByRole("option", { name: "Next result" })).toBe(previousRow);
    expect(previousRow).toHaveAttribute("aria-disabled", "true");
    expect(screen.getByRole("listbox")).toHaveAttribute("aria-busy", "true");
    expect(screen.queryByText("No results found.")).not.toBeInTheDocument();
    fireEvent.click(previousRow);
    fireEvent.keyDown(search, { key: "Enter" });
    expect([...container.querySelectorAll('input[type="hidden"]')].map((node) => node.value)).toEqual(["", initial[1]]);

    await waitFor(() => expect(fetch).toHaveBeenCalledTimes(2));
    await waitFor(() => expect(screen.getByRole("status")).toHaveTextContent("Searching…"));
    expect(screen.getByRole("status")).toHaveClass("sr-only");
    expect(previousRow).toBeInTheDocument();

    await act(async () => {
      resolveSearch(response([["Updated result", "7"]]));
    });
    expect(screen.queryByRole("option", { name: "Next result" })).not.toBeInTheDocument();
    expect(screen.getByRole("option", { name: "Updated result" })).toHaveAttribute("aria-disabled", "false");
    expect(screen.getByRole("status")).toBeEmptyDOMElement();
  });

  it("shows the input spinner during the debounce and clears it when results arrive", async () => {
    vi.useFakeTimers();
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(response([next])));
    render(<AssociationSelect {...props} />);
    fireEvent.click(screen.getByRole("combobox"));
    const indicator = document.querySelector('[data-slot="association-search-indicator"]');
    expect(indicator.querySelector(".animate-spin")).not.toBeNull();
    expect(screen.getByRole("status")).toHaveTextContent("Searching…");
    expect(screen.queryByText("No results found.")).not.toBeInTheDocument();
    await act(async () => {
      await vi.advanceTimersByTimeAsync(200);
    });
    expect(screen.getByRole("option", { name: "Next result" })).toBeInTheDocument();
    expect(document.querySelector('[data-slot="association-search-indicator"]')).toBe(indicator);
    expect(indicator.querySelector(".animate-spin")).toBeNull();
    await act(async () => {
      await vi.advanceTimersByTimeAsync(1000);
    });
    expect(screen.getByRole("status")).toBeEmptyDOMElement();
    expect(screen.getByRole("listbox")).toHaveAttribute("aria-busy", "false");
  });

  it("focuses a retained matching result after the search finishes", async () => {
    vi.stubGlobal(
      "fetch",
      vi
        .fn()
        .mockResolvedValueOnce(
          response([
            ["First result", "1"],
            ["Matching result", "2"]
          ])
        )
        .mockResolvedValueOnce(response([["Matching result", "2"]]))
    );
    const { container } = render(<AssociationSelect {...props} />);
    fireEvent.click(screen.getByRole("combobox"));
    await screen.findByRole("option", { name: "First result" });
    const search = screen.getByRole("combobox", { name: "Search Publishers" });
    fireEvent.change(search, { target: { value: "Matching" } });
    await waitFor(() => expect(window.fetch).toHaveBeenCalledTimes(2));
    await waitFor(() => expect(screen.getByRole("listbox")).toHaveAttribute("aria-busy", "false"));
    expect(screen.getByRole("option", { name: "Matching result" })).toHaveAttribute("data-selected", "true");
    fireEvent.keyDown(search, { key: "Enter" });
    expect([...container.querySelectorAll('input[type="hidden"]')].map((node) => node.value)).toEqual([
      "",
      initial[1],
      "2"
    ]);
  });

  it("keeps the input spinner active until the response arrives without showing an early empty state", async () => {
    vi.useFakeTimers();
    let resolveSearch;
    vi.stubGlobal(
      "fetch",
      vi.fn(
        () =>
          new Promise((resolve) => {
            resolveSearch = resolve;
          })
      )
    );
    render(<AssociationSelect {...props} />);
    fireEvent.click(screen.getByRole("combobox"));
    await act(async () => {
      await vi.advanceTimersByTimeAsync(499);
    });
    expect(screen.getByRole("status")).toHaveTextContent("Searching…");
    expect(screen.queryByText("No results found.")).not.toBeInTheDocument();
    await act(async () => {
      await vi.advanceTimersByTimeAsync(1);
    });
    expect(screen.getByRole("status")).toHaveTextContent("Searching…");
    await act(async () => {
      resolveSearch(response([]));
    });
    expect(screen.getByText("No results found.")).toBeInTheDocument();
    expect(screen.getByRole("status")).toBeEmptyDOMElement();
  });

  it("supports arrow keys and Enter with duplicate labels and preserves the chosen key", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue(
        response([
          ["Same publisher", "9007199254740995"],
          ["Same publisher", "9007199254740996"]
        ])
      )
    );
    const { container } = render(<AssociationSelect {...props} />);
    fireEvent.keyDown(screen.getByRole("combobox"), { key: "ArrowDown" });
    const items = await screen.findAllByRole("option", { name: "Same publisher" });
    await waitFor(() => expect(items[0]).toHaveAttribute("data-selected", "true"));
    const search = screen.getByRole("combobox", { name: "Search Publishers" });
    expect(search).toHaveFocus();
    fireEvent.keyDown(search, { key: "ArrowDown" });
    fireEvent.keyDown(search, { key: "Enter" });
    expect([...container.querySelectorAll('input[type="hidden"]')].map((node) => node.value)).toEqual([
      "",
      initial[1],
      "9007199254740996"
    ]);
    expect(items[1]).toHaveAttribute("aria-checked", "true");
    fireEvent.keyDown(search, { key: "Escape" });
    await waitFor(() => expect(screen.queryByRole("listbox")).not.toBeInTheDocument());
  });

  it("removes an integrated selection without opening the popover", () => {
    vi.stubGlobal("fetch", vi.fn());
    render(<AssociationSelect {...props} />);
    fireEvent.click(screen.getByRole("button", { name: "Remove Existing" }));
    expect(screen.getByRole("combobox")).toHaveAttribute("aria-expanded", "false");
    expect(window.fetch).not.toHaveBeenCalled();
    expect(screen.queryByRole("button", { name: "Remove Existing" })).not.toBeInTheDocument();
  });

  it("searches without pagination and preserves selections through searching and clearing", async () => {
    const fetch = vi
      .fn()
      .mockResolvedValueOnce(response([next]))
      .mockResolvedValueOnce(response([]));
    vi.stubGlobal("fetch", fetch);
    const { container } = render(<AssociationSelect {...props} />);
    expect(fetch).not.toHaveBeenCalled();
    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(await screen.findByRole("option", { name: "Next result" }));
    expect(screen.queryByRole("button", { name: "Next", exact: true })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Previous", exact: true })).not.toBeInTheDocument();
    fireEvent.change(screen.getByRole("combobox", { name: "Search Publishers" }), {
      target: { value: "missing" }
    });
    await screen.findByText("No results found.");
    expect(fetch.mock.calls[1][0].searchParams.get("search")).toBe("missing");
    expect(fetch.mock.calls[1][0].searchParams.has("page")).toBe(false);
    const values = () => [...container.querySelectorAll('input[type="hidden"]')].map((node) => node.value);
    expect(values()).toEqual(["", initial[1], next[1]]);
    fireEvent.click(screen.getByRole("button", { name: "Remove Existing" }));
    fireEvent.click(screen.getByRole("button", { name: "Remove Next result" }));
    expect(values()).toEqual([""]);
  });

  it("ignores an old response even when fetch does not honor abort", async () => {
    let resolveOld;
    const fetch = vi
      .fn()
      .mockImplementationOnce(
        () =>
          new Promise((resolve) => {
            resolveOld = resolve;
          })
      )
      .mockResolvedValueOnce(response([next]));
    vi.stubGlobal("fetch", fetch);
    render(<AssociationSelect {...props} />);
    fireEvent.click(screen.getByRole("combobox"));
    await waitFor(() => expect(fetch).toHaveBeenCalledTimes(1));
    fireEvent.change(screen.getByRole("combobox", { name: "Search Publishers" }), {
      target: { value: "Next" }
    });
    await screen.findByRole("option", { name: "Next result" });
    expect(fetch.mock.calls[0][1].signal.aborted).toBe(true);
    await act(async () => {
      resolveOld(response([["Stale", "4"]]));
    });
    expect(screen.queryByText("Stale")).not.toBeInTheDocument();
    expect(screen.getByRole("option", { name: "Next result" })).toBeInTheDocument();
  });

  it("keeps the selected value after a failed request and permits retry", async () => {
    vi.stubGlobal(
      "fetch",
      vi
        .fn()
        .mockRejectedValueOnce(new Error("offline"))
        .mockResolvedValueOnce(response([next]))
    );
    const { container } = render(<AssociationSelect {...props} multiple={false} value={initial[1]} />);
    fireEvent.click(screen.getByRole("combobox"));
    await screen.findByRole("alert");
    expect(container.querySelectorAll('input[type="hidden"]')[1].value).toBe(initial[1]);
    fireEvent.click(screen.getByRole("button", { name: "Try again" }));
    fireEvent.click(await screen.findByRole("option", { name: "Next result" }));
    expect(container.querySelectorAll('input[type="hidden"]')[1].value).toBe(next[1]);
  });
});
