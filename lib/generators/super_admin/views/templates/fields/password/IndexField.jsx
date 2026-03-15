import React from "react";

export function IndexField({ value }) {
  if (!value) return <span className="text-muted-foreground">-</span>;
  return <span className="text-sm tracking-widest">{"••••••••"}</span>;
}
