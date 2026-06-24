import React from "react";
import { CheckCircle2, XCircle } from "lucide-react";

export function ShowField({ value }) {
  if (value == null) return <span className="text-muted-foreground">-</span>;

  const Icon = value ? CheckCircle2 : XCircle;
  const label = value ? "Yes" : "No";

  return (
    <span className="inline-flex items-center gap-1">
      <Icon className="h-4 w-4" aria-hidden="true" />
      {label}
    </span>
  );
}
