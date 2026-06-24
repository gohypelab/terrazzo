import React, { useContext } from "react";
import { NavigationContext } from "@thoughtbot/superglue";

import { getComponent } from "../componentRegistry";
import { SortableHeader as DefaultSortableHeader } from "./SortableHeader";
import { CollectionItemActions as DefaultCollectionItemActions } from "./CollectionItemActions";
import { FieldRenderer } from "terrazzo/fields";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "terrazzo/ui";

export function ResourceTable({ headers, rows, emptyState, showActions = true }) {
  const { visit } = useContext(NavigationContext);
  const SortableHeader = getComponent("SortableHeader") || DefaultSortableHeader;
  const CollectionItemActions = getComponent("CollectionItemActions") || DefaultCollectionItemActions;
  const columnCount = headers.length + (showActions ? 1 : 0);

  const handleRowClick = (e, showPath) => {
    if (!showPath) return;
    if (e.target.closest("a, button, form")) return;
    if (window.getSelection().toString()) return;
    visit(showPath, {});
  };

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            {headers.map((header) => (
              <SortableHeader key={header.attribute} {...header} />
            ))}
            {showActions && (
              <TableHead className="w-10">
                <span className="sr-only">Actions</span>
              </TableHead>
            )}
          </TableRow>
        </TableHeader>
        <TableBody>
          {rows.length === 0 ? (
            <TableRow>
              <TableCell colSpan={columnCount} className="h-32 text-center">
                <div className="mx-auto flex max-w-sm flex-col items-center gap-1">
                  <p className="text-sm font-medium">{emptyState?.title ?? "No records found"}</p>
                  {emptyState?.description && (
                    <p className="text-sm text-muted-foreground">{emptyState.description}</p>
                  )}
                </div>
              </TableCell>
            </TableRow>
          ) : rows.map((row) => (
            <TableRow
              key={row.id}
              className={row.showPath ? "cursor-pointer" : ""}
              onClick={(e) => handleRowClick(e, row.showPath)}
            >
              {row.cells.map((cell) => {
                const cellClassName = cell.cellOptions?.className || cell.cellOptions?.class_name;
                return (
                  <TableCell key={cell.attribute} className={cellClassName}>
                    {cell.showPath ? (
                      <a
                        href={cell.showPath}
                        data-sg-visit
                        className="hover:underline"
                      >
                        <FieldRenderer mode="index" {...cell} />
                      </a>
                    ) : (
                      <FieldRenderer mode="index" {...cell} />
                    )}
                  </TableCell>
                );
              })}
              {showActions && (
                <TableCell>
                  <CollectionItemActions actions={row.collectionItemActions} />
                </TableCell>
              )}
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
