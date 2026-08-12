import React from "react";
import { fireEvent, render, screen } from "@testing-library/react";

import { FormField } from "./boolean/FormField";

describe("Boolean FormField", () => {
  it("submits 0 after an initially checked field is unchecked", () => {
    const { container } = render(
      <form>
        <FormField
          value={true}
          label="Reviewed"
          input={{ id: "placement_reviewed", name: "placement[reviewed]" }}
        />
      </form>
    );

    fireEvent.click(screen.getByRole("checkbox", { name: "Reviewed" }));

    const formData = new FormData(container.querySelector("form"));
    expect(formData.get("placement[reviewed]")).toBe("0");
  });

  it("submits 1 when checked", () => {
    const { container } = render(
      <form>
        <FormField
          value={false}
          label="Reviewed"
          input={{ id: "placement_reviewed", name: "placement[reviewed]" }}
        />
      </form>
    );

    fireEvent.click(screen.getByRole("checkbox", { name: "Reviewed" }));

    const formData = new FormData(container.querySelector("form"));
    expect(formData.getAll("placement[reviewed]")).toEqual(["0", "1"]);
  });
});
