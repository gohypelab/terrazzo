import React from "react";

import { Badge } from "terrazzo/ui";

export function ShowField({ value }) {
  if (value == null || Object.keys(value).length === 0) {
    return <span className="text-muted-foreground">No data</span>;
  }

  const entries = Object.entries(value);

  return (
    <div className="space-y-1.5">
      {entries.map(([k, v]) => (
        <div key={k} className="flex items-start gap-2">
          <Badge variant="outline" className="font-mono text-xs shrink-0">
            {k}
          </Badge>
          <span className="text-sm break-all">{String(v ?? "")}</span>
        </div>
      ))}
    </div>
  );
}
