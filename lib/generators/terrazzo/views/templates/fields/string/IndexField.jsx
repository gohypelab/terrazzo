import React from "react";

export function IndexField({ value }) {
  return <span className="text-sm">{String(value ?? "")}</span>;
}
