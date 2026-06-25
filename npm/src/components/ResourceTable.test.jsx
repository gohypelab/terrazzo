import React from "react";
import { render, screen } from "@testing-library/react";

import { registerFieldType } from "terrazzo/fields";
import { ResourceTable } from "./ResourceTable";

function resetFieldRegistry() {
  Object.keys(globalThis.__terrazzoFieldRegistry || {}).forEach((key) => {
    delete globalThis.__terrazzoFieldRegistry[key];
  });
}

describe("ResourceTable", () => {
  beforeEach(resetFieldRegistry);
  afterEach(resetFieldRegistry);

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

  it("passes serialized cell metadata to registered field renderers", () => {
    function CustomStatusField({ cellOptions, value }) {
      return (
        <span data-testid="custom-status-field">
          {value}:{cellOptions.meta.tone}
        </span>
      );
    }

    registerFieldType("status", { index: CustomStatusField });

    render(
      <ResourceTable
        headers={[
          {
            attribute: "status",
            label: "Status",
            sortable: false,
          },
        ]}
        rows={[
          {
            id: "order-1",
            cells: [
              {
                attribute: "status",
                fieldType: "status",
                value: "Overdue",
                cellOptions: { meta: { tone: "danger" } },
              },
            ],
            collectionItemActions: [],
          },
        ]}
        showActions={false}
      />
    );

    expect(screen.getByTestId("custom-status-field")).toHaveTextContent("Overdue:danger");
  });
});
