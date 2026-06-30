import React from "react";
import { Mail } from "lucide-react";

export function ShowField({ value }) {
  if (!value) return <span className="text-muted-foreground">-</span>;
  return (
    <a href={`mailto:${value}`} className="inline-flex items-center gap-1 text-primary hover:underline">
      <Mail className="h-4 w-4" aria-hidden="true" />
      {String(value)}
    </a>);

}
