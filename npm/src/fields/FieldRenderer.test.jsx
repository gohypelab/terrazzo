import React from "react";
import { render, screen } from "@testing-library/react";

import { FieldRenderer, registerFieldType } from "./FieldRenderer";

function resetFieldRegistry() {
  Object.keys(globalThis.__terrazzoFieldRegistry || {}).forEach((key) => {
    delete globalThis.__terrazzoFieldRegistry[key];
  });
}

describe("FieldRenderer registry overrides", () => {
  beforeEach(resetFieldRegistry);
  afterEach(resetFieldRegistry);

  it("renders a registered component for the requested field type and mode", () => {
    function CustomStringFormField({ value, input }) {
      return (
        <label data-testid="custom-string-form">
          Custom form: {value}
          <input {...input} />
        </label>
      );
    }

    registerFieldType("string", { form: CustomStringFormField });

    render(
      <FieldRenderer
        mode="form"
        fieldType="string"
        value="Alice"
        input={{ name: "customer[name]" }}
      />
    );

    expect(screen.getByTestId("custom-string-form")).toHaveTextContent("Custom form: Alice");
    expect(screen.getByRole("textbox")).toHaveAttribute("name", "customer[name]");
  });

  it("falls back to the packaged component for modes without an override", () => {
    function CustomStringIndexField({ value }) {
      return <span data-testid="custom-string-index">Custom index: {value}</span>;
    }

    registerFieldType("string", { index: CustomStringIndexField });

    render(<FieldRenderer mode="show" fieldType="string" value="Alice" />);

    expect(screen.queryByTestId("custom-string-index")).not.toBeInTheDocument();
    expect(screen.getByText("Alice")).toBeInTheDocument();
  });
});
