import React from "react";
import { Mail } from "lucide-react";

export function IndexField({ value }) {
  if (!value) return <span className="text-muted-foreground">-</span>;
  return (
    <a href={`mailto:${value}`} className="inline-flex items-center gap-1 text-sm text-primary hover:underline">
      <Mail className="h-3.5 w-3.5" aria-hidden="true" />
      {String(value)}
    </a>);

}
