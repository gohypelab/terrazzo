import React from "react";
import { render } from "@testing-library/react";

import { ResourceTable } from "./ResourceTable";

describe("ResourceTable", () => {
  it("applies serialized row option classes while preserving row click styling", () => {
    const { container } = render(
      <ResourceTable
        headers={[
          {
            attribute: "name",
            label: "Name",
            sortable: false,
            headerOptions: { className: "w-64 text-right" },
          },
        ]}
        rows={[
          {
            id: "customer-1",
            showPath: "/admin/customers/1",
            rowOptions: { className: "bg-muted/40 font-medium" },
            cells: [
              {
                attribute: "name",
                fieldType: "string",
                value: "Alice",
              },
            ],
            collectionItemActions: [],
          },
        ]}
        showActions={false}
      />
    );

    const header = container.querySelector("thead th");
    const row = container.querySelector("tbody tr");

    expect(header).toHaveClass("w-64");
    expect(header).toHaveClass("text-right");
    expect(row).toHaveClass("cursor-pointer");
    expect(row).toHaveClass("bg-muted/40");
    expect(row).toHaveClass("font-medium");
  });
});
