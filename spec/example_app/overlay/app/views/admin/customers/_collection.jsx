import React from "react";

import { FieldRenderer } from "../fields";

// Minimal card-grid override that replaces the default ResourceTable. This is
// the page-level "look and feel" seam-proof: the customers index renders cards
// in a grid (no <table>), and the customizations spec asserts the default table
// is absent and the card grid + count badge are present.
export function CustomerCollection({ table = {}, emptyState }) {
  const { headers = [], rows = [] } = table || {};

  if (rows.length === 0) {
    return (
      <div className="rounded-lg border p-8 text-center text-sm text-muted-foreground">
        {emptyState?.title ?? "No customers found"}
      </div>
    );
  }

  return (
    <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
      {rows.map((row) => (
        <a
          key={row.id}
          href={row.showPath}
          data-sg-visit
          className="rounded-lg border bg-card p-4 shadow-sm transition-colors hover:bg-muted/40">

          <div className="space-y-2">
            {row.cells.map((cell) => (
              <div key={cell.attribute} className="flex items-start justify-between gap-3">
                <span className="text-xs font-medium uppercase text-muted-foreground">
                  {headers.find((header) => header.attribute === cell.attribute)?.label ?? cell.attribute}
                </span>
                <span className="text-right text-sm">
                  <FieldRenderer mode="index" {...cell} />
                </span>
              </div>
            ))}
          </div>
        </a>
      ))}
    </div>
  );
}
