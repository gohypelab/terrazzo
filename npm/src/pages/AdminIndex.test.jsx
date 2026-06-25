import React from "react";
import { render, screen } from "@testing-library/react";

import { registerComponent } from "../componentRegistry";
import { setLayout } from "../layoutRegistry";
import AdminIndex from "./AdminIndex";

const mockUseContent = vi.hoisted(() => vi.fn());

vi.mock("@thoughtbot/superglue", async () => {
  const ReactModule = await vi.importActual("react");

  return {
    NavigationContext: ReactModule.createContext({}),
    useContent: () => mockUseContent(),
  };
});

function resetComponentRegistry() {
  Object.keys(globalThis.__terrazzoComponentRegistry || {}).forEach((key) => {
    delete globalThis.__terrazzoComponentRegistry[key];
  });
}

function resetLayoutRegistry() {
  delete (globalThis.__terrazzoLayoutRegistry || {}).Component;
}

describe("AdminIndex registry overrides", () => {
  beforeEach(() => {
    resetComponentRegistry();
    resetLayoutRegistry();
    mockUseContent.mockReset();
  });

  afterEach(() => {
    resetComponentRegistry();
    resetLayoutRegistry();
    mockUseContent.mockReset();
  });

  it("renders registered package-page components before ejection", () => {
    function CustomLayout({ title, actions, children }) {
      return (
        <main data-testid="custom-layout">
          <h1>{title}</h1>
          <div data-testid="layout-actions">{actions}</div>
          {children}
        </main>
      );
    }

    function CustomSearchBar({ query }) {
      return <div data-testid="custom-search">Search: {query}</div>;
    }

    function CustomCollectionFilters({ facets }) {
      return <div data-testid="custom-filters">Facets: {facets.length}</div>;
    }

    function CustomCollectionToolbarActions({ actions = [] }) {
      return (
        <div data-testid="custom-toolbar">
          {actions.map((action) => action.label).join(", ")}
        </div>
      );
    }

    function CustomResourceTable({ headers, rows, emptyState }) {
      return (
        <div data-testid="custom-resource-table">
          {headers.length} headers, {rows.length} rows, {emptyState.title}
        </div>
      );
    }

    function CustomPagination({ currentPage, totalPages }) {
      return (
        <div data-testid="custom-pagination">
          Page {currentPage} of {totalPages}
        </div>
      );
    }

    setLayout(CustomLayout);
    registerComponent("SearchBar", CustomSearchBar);
    registerComponent("CollectionFilters", CustomCollectionFilters);
    registerComponent("CollectionToolbarActions", CustomCollectionToolbarActions);
    registerComponent("ResourceTable", CustomResourceTable);
    registerComponent("Pagination", CustomPagination);

    mockUseContent.mockReturnValue({
      table: {
        headers: [{ attribute: "name", label: "Name" }],
        rows: [{ id: "order-1", cells: [] }],
      },
      searchBar: { query: "alice" },
      filters: { facets: [{ name: "status" }] },
      pagination: { currentPage: 2, totalPages: 5 },
      layoutActions: [{ label: "Export", url: "/admin/orders.csv" }],
      toolbarActions: [{ label: "Sync", url: "/admin/orders/sync" }],
      emptyState: { title: "No orders" },
      navigation: [],
      newResourcePath: "/admin/orders/new",
      resourceName: "Orders",
      singularResourceName: "Order",
    });

    render(<AdminIndex />);

    expect(screen.getByTestId("custom-layout")).toHaveTextContent("Orders");
    expect(screen.getByTestId("custom-search")).toHaveTextContent("Search: alice");
    expect(screen.getByTestId("custom-filters")).toHaveTextContent("Facets: 1");
    expect(screen.getByTestId("custom-resource-table")).toHaveTextContent("1 headers, 1 rows, No orders");
    expect(screen.getByTestId("custom-pagination")).toHaveTextContent("Page 2 of 5");
    expect(screen.getByRole("link", { name: "New Order" })).toHaveAttribute("href", "/admin/orders/new");
    expect(screen.getAllByTestId("custom-toolbar").map((node) => node.textContent)).toEqual([
      "Export",
      "Sync",
    ]);
  });
});
