import React from "react";
import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import { AssociationSelect } from "./AssociationSelect";

const initial = ["Existing", "9007199254740993"];
const next = ["Next result", "9007199254740994"];
const response = (items) => ({
  ok: true,
  json: async () => ({ resourceOptions: items }),
});
const props = {
  multiple: true,
  value: [initial[1]],
  label: "Publishers",
  input: { name: "property[publisher_ids][]", id: "publishers" },
  options: {
    resourceOptions: [initial],
    optionsUrl: "/admin/properties/example/edit.json?association=publishers",
  },
};

describe("AssociationSelect", () => {
  afterEach(() => vi.unstubAllGlobals());

  it("searches without pagination and preserves selections through searching and clearing", async () => {
    const fetch = vi
      .fn()
      .mockResolvedValueOnce(response([next]))
      .mockResolvedValueOnce(response([]));
    vi.stubGlobal("fetch", fetch);
    const { container } = render(<AssociationSelect {...props} />);
    expect(fetch).not.toHaveBeenCalled();
    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(await screen.findByRole("button", { name: "Next result" }));
    expect(screen.queryByRole("button", { name: "Next", exact: true })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Previous", exact: true })).not.toBeInTheDocument();
    fireEvent.change(screen.getByRole("textbox"), {
      target: { value: "missing" },
    });
    await screen.findByText("No results found.");
    expect(fetch.mock.calls[1][0].searchParams.get("search")).toBe("missing");
    expect(fetch.mock.calls[1][0].searchParams.has("page")).toBe(false);
    const values = () =>
      [...container.querySelectorAll('input[type="hidden"]')].map(
        (node) => node.value,
      );
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
          }),
      )
      .mockResolvedValueOnce(response([next]));
    vi.stubGlobal("fetch", fetch);
    render(<AssociationSelect {...props} />);
    fireEvent.click(screen.getByRole("combobox"));
    await waitFor(() => expect(fetch).toHaveBeenCalledTimes(1));
    fireEvent.change(screen.getByRole("textbox"), {
      target: { value: "Next" },
    });
    await screen.findByRole("button", { name: "Next result" });
    expect(fetch.mock.calls[0][1].signal.aborted).toBe(true);
    await act(async () => {
      resolveOld(response([["Stale", "4"]]));
    });
    expect(screen.queryByText("Stale")).not.toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: "Next result" }),
    ).toBeInTheDocument();
  });

  it("keeps the selected value after a failed request and permits retry", async () => {
    vi.stubGlobal(
      "fetch",
      vi
        .fn()
        .mockRejectedValueOnce(new Error("offline"))
        .mockResolvedValueOnce(response([next])),
    );
    const { container } = render(
      <AssociationSelect {...props} multiple={false} value={initial[1]} />,
    );
    fireEvent.click(screen.getByRole("combobox"));
    await screen.findByRole("alert");
    expect(container.querySelectorAll('input[type="hidden"]')[1].value).toBe(
      initial[1],
    );
    fireEvent.click(screen.getByRole("button", { name: "Retry" }));
    fireEvent.click(await screen.findByRole("button", { name: "Next result" }));
    expect(container.querySelectorAll('input[type="hidden"]')[1].value).toBe(
      next[1],
    );
  });
});
