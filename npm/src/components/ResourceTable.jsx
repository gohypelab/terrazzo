import React, { useContext } from "react";
import { NavigationContext } from "@thoughtbot/superglue";

import { SortableHeader } from "./SortableHeader";
import { CollectionItemActions } from "./CollectionItemActions";
import { FieldRenderer } from "terrazzo/fields";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "terrazzo/ui";

export function ResourceTable({ headers, rows, showActions = true }) {
  const { visit } = useContext(NavigationContext);

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
            {showActions && <TableHead className="w-[120px]">Actions</TableHead>}
          </TableRow>
        </TableHeader>
        <TableBody>
          {rows.map((row) => (
            <TableRow
              key={row.id}
              className={row.showPath ? "cursor-pointer" : ""}
              onClick={(e) => handleRowClick(e, row.showPath)}
            >
              {row.cells.map((cell) => (
                <TableCell key={cell.attribute}>
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
              ))}
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
