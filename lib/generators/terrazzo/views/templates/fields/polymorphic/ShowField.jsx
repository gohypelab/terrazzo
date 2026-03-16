import React from "react";

export function ShowField({ value }) {
  const assoc = value;
  if (!assoc) return <span className="text-muted-foreground">-</span>;
  return <span>{assoc.display}</span>;
}
