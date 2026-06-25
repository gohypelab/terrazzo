import React from "react";
import { render, screen } from "@testing-library/react";

import { registerComponent } from "../componentRegistry";
import { AdminCollection } from "./AdminCollection";

function resetComponentRegistry() {
  Object.keys(globalThis.__terrazzoComponentRegistry || {}).forEach((key) => {
    delete globalThis.__terrazzoComponentRegistry[key];
  });
}

describe("AdminCollection component registry overrides", () => {
  beforeEach(resetComponentRegistry);
  afterEach(resetComponentRegistry);

  it("renders a registered ResourceTable override", () => {
    function CustomResourceTable({ headers, rows, emptyState }) {
      return (
        <div data-testid="custom-resource-table">
          {headers.length} headers, {rows.length} rows, {emptyState.title}
        </div>
      );
    }

    registerComponent("ResourceTable", CustomResourceTable);

    render(
      <AdminCollection
        table={{
          headers: [{ attribute: "name", label: "Name" }],
          rows: [{ id: "customer-1", cells: [] }],
        }}
        emptyState={{ title: "Nothing here" }}
      />
    );

    expect(screen.getByTestId("custom-resource-table")).toHaveTextContent(
      "1 headers, 1 rows, Nothing here"
    );
  });
});
