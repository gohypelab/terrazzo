import React from "react";
import { render, screen } from "@testing-library/react";

import { registerFieldType } from "terrazzo/fields";
import { AdminForm } from "./AdminForm";

function resetFieldRegistry() {
  Object.keys(globalThis.__terrazzoFieldRegistry || {}).forEach((key) => {
    delete globalThis.__terrazzoFieldRegistry[key];
  });
}

describe("AdminForm", () => {
  beforeEach(resetFieldRegistry);
  afterEach(resetFieldRegistry);

  it("resolves group attributes from the one field list", () => {
    registerFieldType("contract", { form: ({ value }) => <span>{value}</span> });
    render(<AdminForm form={{
      fields: [{ attribute: "name", fieldType: "contract", value: "Grouped name" }],
      fieldGroups: [{ name: "Details", attributes: ["name"] }]
    }} />);
    expect(screen.getAllByText("Grouped name")).toHaveLength(1);
    expect(screen.getByRole("group", { name: "Details" })).toBeInTheDocument();
  });

  it("falls back to fields when custom props omit field groups", () => {
    function ContractFormField({ input, value }) {
      return (
        <label data-testid="contract-form-field">
          Contract field: {value}
          <input {...input} />
        </label>
      );
    }

    registerFieldType("contract", { form: ContractFormField });

    render(
      <AdminForm
        form={{
          props: { action: "/admin/contracts", method: "post" },
          fieldGroups: [],
          fields: [
            {
              attribute: "name",
              fieldType: "contract",
              value: "Alice",
              input: { name: "contract[name]" },
            },
          ],
        }}
      />
    );

    expect(screen.getByTestId("contract-form-field")).toHaveTextContent("Contract field: Alice");
    expect(screen.getByRole("textbox")).toHaveAttribute("name", "contract[name]");
  });
});
