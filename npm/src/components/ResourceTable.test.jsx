import React from "react";
import { render } from "@testing-library/react";

import { ResourceTable } from "./ResourceTable";

describe("ResourceTable", () => {
  it("applies serialized row option classes while preserving row click styling", () => {
    const { container } = render(
      <ResourceTable
        headers={[]}
        rows={[
          {
            id: "customer-1",
            showPath: "/admin/customers/1",
            rowOptions: { className: "bg-muted/40 font-medium" },
            cells: [],
            collectionItemActions: [],
          },
        ]}
        showActions={false}
      />
    );

    const row = container.querySelector("tbody tr");

    expect(row).toHaveClass("cursor-pointer");
    expect(row).toHaveClass("bg-muted/40");
    expect(row).toHaveClass("font-medium");
  });
});
