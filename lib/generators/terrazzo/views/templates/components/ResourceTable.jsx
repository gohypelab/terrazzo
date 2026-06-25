import React, { useContext, useState } from "react";
import { NavigationContext } from "@thoughtbot/superglue";

import { SortableHeader as DefaultSortableHeader } from "./SortableHeader";
import { CollectionItemActions as DefaultCollectionItemActions } from "./CollectionItemActions";
import { CollectionToolbarActions as DefaultCollectionToolbarActions } from "./CollectionToolbarActions";
import { getComponent, cn } from "terrazzo";
import { FieldRenderer } from "../fields";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "./ui";

export function ResourceTable({ headers = [], rows = [], emptyState, showActions = true, bulkActions = [] }) {
  const { visit } = useContext(NavigationContext);
  const SortableHeader = getComponent("SortableHeader") || DefaultSortableHeader;
  const CollectionItemActions = getComponent("CollectionItemActions") || DefaultCollectionItemActions;
  const CollectionToolbarActions = getComponent("CollectionToolbarActions") || DefaultCollectionToolbarActions;
  const safeHeaders = Array.isArray(headers) ? headers : [];
  const safeRows = Array.isArray(rows) ? rows : [];
  const safeBulkActions = Array.isArray(bulkActions) ? bulkActions : [];
  const selectable = safeBulkActions.length > 0 && safeRows.length > 0;
  const rowIds = safeRows.map((row) => String(row.id));
  const [selectedIds, setSelectedIds] = useState(() => new Set());
  const selectedRowIds = rowIds.filter((id) => selectedIds.has(id));
  const selectedCount = selectedRowIds.length;
  const allSelected = selectable && selectedCount === rowIds.length;
  const someSelected = selectedCount > 0 && !allSelected;
  const columnCount = safeHeaders.length + (showActions ? 1 : 0) + (selectable ? 1 : 0);

  const handleRowClick = (e, showPath) => {
    if (!showPath) return;
    if (e.target.closest("a, button, form, input, label")) return;
    if (window.getSelection().toString()) return;
    visit(showPath, {});
  };

  const toggleRow = (id, checked) => {
    setSelectedIds((current) => {
      const next = new Set(current);
      if (checked) {
        next.add(id);
      } else {
        next.delete(id);
      }
      return next;
    });
  };

  const toggleAllRows = (checked) => {
    setSelectedIds((current) => {
      const next = new Set(current);
      rowIds.forEach((id) => {
        if (checked) {
          next.add(id);
        } else {
          next.delete(id);
        }
      });
      return next;
    });
  };

  return (
    <div className="rounded-md border">
      {selectable && (
        <div className="flex flex-col gap-2 border-b px-4 py-3 sm:flex-row sm:items-center sm:justify-between">
          <p className="text-sm text-muted-foreground">
            {selectedCount} {selectedCount === 1 ? "row" : "rows"} selected
          </p>
          <div className="flex flex-wrap gap-2">
            <CollectionToolbarActions
              actions={safeBulkActions}
              selectedIds={selectedRowIds}
              disabled={selectedCount === 0}
            />
          </div>
        </div>
      )}
      <Table>
        <TableHeader>
          <TableRow>
            {selectable && (
              <TableHead className="w-10">
                <input
                  type="checkbox"
                  aria-label="Select all rows"
                  checked={allSelected}
                  ref={(element) => {
                    if (element) element.indeterminate = someSelected;
                  }}
                  onChange={(event) => toggleAllRows(event.target.checked)}
                  className="h-4 w-4 rounded border"
                />
              </TableHead>
            )}
            {safeHeaders.map((header) => (
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
          {safeRows.length === 0 ? (
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
          ) : safeRows.map((row) => (
            <TableRow
              key={row.id}
              className={cn(
                row.showPath && "cursor-pointer",
                row.rowOptions?.className || row.rowOptions?.class_name
              )}
              onClick={(e) => handleRowClick(e, row.showPath)}
            >
              {selectable && (
                <TableCell>
                  <input
                    type="checkbox"
                    aria-label={`Select row ${row.id}`}
                    checked={selectedIds.has(String(row.id))}
                    onChange={(event) => toggleRow(String(row.id), event.target.checked)}
                    className="h-4 w-4 rounded border"
                  />
                </TableCell>
              )}
              {(Array.isArray(row.cells) ? row.cells : []).map((cell) => {
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
