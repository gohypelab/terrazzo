import React from "react";

export function ShowField({ value }) {
  if (!value) return <span className="text-muted-foreground">-</span>;
  return (
    <a href={String(value)} target="_blank" rel="noopener noreferrer" className="text-primary hover:underline">
      {String(value)}
    </a>);

}
