import React from "react";
import { fireEvent, render, screen } from "@testing-library/react";

import { SearchBar } from "./SearchBar";

const mockVisit = vi.hoisted(() => vi.fn());

vi.mock("@thoughtbot/superglue", async () => {
  const ReactModule = await vi.importActual("react");

  return {
    NavigationContext: ReactModule.createContext({ visit: mockVisit }),
  };
});

describe("SearchBar", () => {
  beforeEach(() => {
    mockVisit.mockReset();
    window.history.pushState({}, "", "/admin/customers?_page=3&per_page=10000&order=name");
  });

  it("submits search with the normalized per-page value", () => {
    render(<SearchBar searchPath="/admin/customers" perPage={100} />);

    fireEvent.change(screen.getByRole("searchbox"), { target: { value: "Alice" } });
    fireEvent.submit(screen.getByRole("searchbox").closest("form"));

    expect(mockVisit).toHaveBeenCalledWith(
      "/admin/customers?per_page=100&order=name&search=Alice",
      {}
    );
  });
});
