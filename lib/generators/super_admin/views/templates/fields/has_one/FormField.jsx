import React from "react";

export function FormField({ value }) {
  const assoc = value;
  if (!assoc) return <span className="text-muted-foreground">-</span>;
  return <span>{assoc.display}</span>;
}
