import React from "react";

export function ShowField({ value }) {
  if (!value) return <span className="text-muted-foreground">-</span>;
  return <div className="prose max-w-none" dangerouslySetInnerHTML={{ __html: String(value) }} />;
}
