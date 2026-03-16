import React from "react";

export function IndexField({ value }) {
  if (!value) return <span className="text-muted-foreground">-</span>;
  return (
    <a href={`mailto:${value}`} className="text-sm text-primary hover:underline">
      {String(value)}
    </a>);

}
