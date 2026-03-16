import React from "react";

export function ShowField({ value }) {
  if (!value) return <span className="text-muted-foreground">-</span>;
  return (
    <a href={`mailto:${value}`} className="text-primary hover:underline">
      {String(value)}
    </a>);

}
