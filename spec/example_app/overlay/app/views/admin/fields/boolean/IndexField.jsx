import React from "react";
import { CheckCircle2, XCircle } from "lucide-react";

export function IndexField({ value }) {
  if (value == null) return <span className="text-muted-foreground">-</span>;
  const Icon = value ? CheckCircle2 : XCircle;
  return (
    <span className="inline-flex items-center gap-1 text-sm">
      <Icon className="h-4 w-4" aria-hidden="true" />
      {value ? "Yes" : "No"}
    </span>);

}
