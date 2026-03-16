import React from "react";

export function IndexField({ value }) {
  const assoc = value;
  if (!assoc) return <span className="text-muted-foreground">-</span>;
  return <span className="text-sm">{assoc.display}</span>;
}
