import React from "react";

export function IndexField({ value }) {
  if (!value) return <span className="text-muted-foreground">-</span>;
  const text = String(value).replace(/<[^>]*>/g, "");
  const truncated = text.length > 50 ? text.slice(0, 50) + "..." : text;
  return <span className="text-sm">{truncated}</span>;
}
