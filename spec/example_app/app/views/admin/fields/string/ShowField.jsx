import React from "react";

export function ShowField({ value }) {
  return <span data-testid="custom-string-show-field">{String(value ?? "")}</span>;
}
