import React from "react";

export function ShowField({ value }) {
  if (value == null) return <span className="text-muted-foreground">-</span>;
  return <span>{value ? "Yes" : "No"}</span>;
}
