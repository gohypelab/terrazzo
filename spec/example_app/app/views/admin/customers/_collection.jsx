import React from "react";

import { FieldRenderer } from "../fields";
import { Button } from "../components/ui";

export function CustomerCollection({ table, emptyState }) {
  if (table.rows.length === 0) {
    return (
      <div className="rounded-lg border p-8 text-center">
        <p className="text-sm font-medium">{emptyState?.title ?? "No customers found"}</p>
        {emptyState?.description && (
          <p className="mt-1 text-sm text-muted-foreground">{emptyState.description}</p>
        )}
      </div>
    );
  }

  return (
    <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
      {table.rows.map((row) => (
        <div key={row.id} className="rounded-lg border bg-card p-4 shadow-sm">
          <div className="space-y-3">
            {row.cells.map((cell) => (
              <div key={cell.attribute} className="flex items-start justify-between gap-3">
                <span className="text-xs font-medium uppercase text-muted-foreground">
                  {table.headers.find((header) => header.attribute === cell.attribute)?.label ?? cell.attribute}
                </span>
                <span className="text-right text-sm">
                  {cell.showPath ? (
                    <a href={cell.showPath} data-sg-visit className="hover:underline">
                      <FieldRenderer mode="index" {...cell} />
                    </a>
                  ) : (
                    <FieldRenderer mode="index" {...cell} />
                  )}
                </span>
              </div>
            ))}
          </div>
          {row.showPath && (
            <div className="mt-4">
              <a href={row.showPath} data-sg-visit>
                <Button variant="outline" size="sm">Open</Button>
              </a>
            </div>
          )}
        </div>
      ))}
    </div>
  );
}
