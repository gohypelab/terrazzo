import React from "react";
import { fireEvent, render, screen } from "@testing-library/react";

import { registerComponent } from "../componentRegistry";
import { registerFieldType } from "terrazzo/fields";
import { ResourceTable } from "./ResourceTable";

function resetComponentRegistry() {
  Object.keys(globalThis.__terrazzoComponentRegistry || {}).forEach((key) => {
    delete globalThis.__terrazzoComponentRegistry[key];
  });
}

function resetFieldRegistry() {
  Object.keys(globalThis.__terrazzoFieldRegistry || {}).forEach((key) => {
    delete globalThis.__terrazzoFieldRegistry[key];
  });
}

describe("ResourceTable", () => {
  beforeEach(() => {
    resetComponentRegistry();
    resetFieldRegistry();
  });

  afterEach(() => {
    resetComponentRegistry();
    resetFieldRegistry();
  });

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

  it("renders registered nested table components", () => {
    function CustomSortableHeader({ label }) {
      return <th data-testid="custom-sortable-header">{label}</th>;
    }

    function CustomCollectionItemActions({ actions }) {
      return (
        <div data-testid="custom-item-actions">
          {actions.map((action) => action.label).join(", ")}
        </div>
      );
    }

    registerComponent("SortableHeader", CustomSortableHeader);
    registerComponent("CollectionItemActions", CustomCollectionItemActions);

    render(
      <ResourceTable
        headers={[
          {
            attribute: "name",
            label: "Customer",
            sortable: false,
          },
        ]}
        rows={[
          {
            id: "customer-1",
            cells: [
              {
                attribute: "name",
                fieldType: "string",
                value: "Alice",
              },
            ],
            collectionItemActions: [{ label: "Archive", url: "/admin/customers/1/archive" }],
          },
        ]}
      />
    );

    expect(screen.getByTestId("custom-sortable-header")).toHaveTextContent("Customer");
    expect(screen.getByTestId("custom-item-actions")).toHaveTextContent("Archive");
  });

  it("renders bulk actions with selected row ids", () => {
    const { container } = render(
      <ResourceTable
        headers={[
          {
            attribute: "name",
            label: "Customer",
            sortable: false,
          },
        ]}
        rows={[
          {
            id: "customer-1",
            cells: [
              {
                attribute: "name",
                fieldType: "string",
                value: "Alice",
              },
            ],
            collectionItemActions: [],
          },
          {
            id: "customer-2",
            cells: [
              {
                attribute: "name",
                fieldType: "string",
                value: "Bob",
              },
            ],
            collectionItemActions: [],
          },
        ]}
        bulkActions={[
          { label: "Archive", url: "/admin/customers/archive", method: "post" },
        ]}
        showActions={false}
      />
    );

    expect(screen.getByText("0 rows selected")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Archive" })).toBeDisabled();

    fireEvent.click(screen.getByLabelText("Select row customer-1"));

    expect(screen.getByText("1 row selected")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Archive" })).not.toBeDisabled();

    const form = container.querySelector('form[action="/admin/customers/archive"]');
    expect(form.querySelectorAll('input[name="ids[]"]')).toHaveLength(1);
    expect(form.querySelector('input[name="ids[]"]')).toHaveValue("customer-1");
  });

  it("renders the empty state when collection arrays are missing", () => {
    render(
      <ResourceTable
        emptyState={{
          title: "No invoices",
          description: "Try a different filter.",
        }}
      />
    );

    expect(screen.getByText("No invoices")).toBeInTheDocument();
    expect(screen.getByText("Try a different filter.")).toBeInTheDocument();
  });
});
