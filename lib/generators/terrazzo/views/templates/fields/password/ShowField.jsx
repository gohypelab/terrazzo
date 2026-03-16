import React from "react";

export function ShowField({ value }) {
  if (!value) return <span className="text-muted-foreground">-</span>;
  return <span className="tracking-widest">{"••••••••"}</span>;
}
