import React from "react";

export function IndexField({ value }) {
  return <span data-testid="custom-string-index-field" className="text-sm">{String(value ?? "")}</span>;
}
