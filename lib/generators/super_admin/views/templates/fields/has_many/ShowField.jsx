import React from "react";

import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "../../components/ui/table";
import { FieldRenderer } from "../FieldRenderer";

export function ShowField({ value }) {
  if (!value) return <span className="text-muted-foreground">None</span>;

  const { items, headers, total, hasMore } = value;

  if (!items || items.length === 0) {
    return <span className="text-muted-foreground">None</span>;
  }

  // Table mode: collection_attributes specified
  if (headers) {
    return (
      <div>
        <div className="rounded-md border">
          <Table>
            <TableHeader>
              <TableRow>
                {headers.map((header) =>
                  <TableHead key={header.attribute}>{header.label}</TableHead>
                )}
              </TableRow>
            </TableHeader>
            <TableBody>
              {items.map((item) =>
                <TableRow key={item.id}>
                  {item.columns.map((col) =>
                    <TableCell key={col.attribute}>
                      <FieldRenderer mode="index" {...col} />
                    </TableCell>
                  )}
                </TableRow>
              )}
            </TableBody>
          </Table>
        </div>
        {hasMore && (
          <p className="text-sm text-muted-foreground mt-2">
            Showing {items.length} of {total}
          </p>
        )}
      </div>
    );
  }

  // Simple list mode
  return (
    <div>
      <ul className="list-disc pl-5 space-y-1">
        {items.map((item) =>
          <li key={item.id}>{item.display}</li>
        )}
      </ul>
      {hasMore && (
        <p className="text-sm text-muted-foreground mt-2">
          Showing {items.length} of {total}
        </p>
      )}
    </div>
  );
}
