import React, { useState, useContext } from "react";
import { NavigationContext } from "@thoughtbot/superglue";

import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "../../components/ui/table";
import { Badge } from "../../components/ui/badge";
import { Button } from "../../components/ui/button";
import { FieldRenderer } from "../FieldRenderer";

export function ShowField({ value, itemShowPaths }) {
  if (!value) return <span className="text-muted-foreground">None</span>;

  const { items, headers, total, initialLimit } = value;
  const [expanded, setExpanded] = useState(false);
  const { visit } = useContext(NavigationContext);

  if (!items || items.length === 0) {
    return <span className="text-muted-foreground">None</span>;
  }

  const pathFor = (id) => itemShowPaths?.[String(id)];
  const hasMore = initialLimit && initialLimit > 0 && total > initialLimit;
  const visibleItems = expanded || !hasMore ? items : items.slice(0, initialLimit);

  const handleRowClick = (e, showPath) => {
    if (!showPath) return;
    if (e.target.closest("a, button, form")) return;
    if (window.getSelection().toString()) return;
    visit(showPath, {});
  };

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
              {visibleItems.map((item) => {
                const showPath = pathFor(item.id);
                return (
                  <TableRow
                    key={item.id}
                    className={showPath ? "cursor-pointer" : ""}
                    onClick={(e) => handleRowClick(e, showPath)}>
                    {item.columns.map((col, colIndex) =>
                      <TableCell key={col.attribute}>
                        {showPath && colIndex === 0 ? (
                          <a href={showPath} data-sg-visit className="hover:underline">
                            <FieldRenderer mode="index" {...col} />
                          </a>
                        ) : (
                          <FieldRenderer mode="index" {...col} />
                        )}
                      </TableCell>
                    )}
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </div>
        {hasMore && (
          <Button
            variant="link"
            size="sm"
            className="mt-2 px-0"
            onClick={() => setExpanded(!expanded)}>
            {expanded ? "Show less" : `Show ${total - initialLimit} more`}
          </Button>
        )}
      </div>
    );
  }

  // Simple list mode
  return (
    <div>
      <div className="flex flex-wrap items-center gap-1.5">
        {visibleItems.map((item) => {
          const showPath = pathFor(item.id);
          return showPath ? (
            <a key={item.id} href={showPath} data-sg-visit>
              <Badge variant="secondary" className="cursor-pointer">{item.display}</Badge>
            </a>
          ) : (
            <Badge key={item.id} variant="secondary">{item.display}</Badge>
          );
        })}
        {hasMore && (
          <Button
            variant="link"
            size="sm"
            className="px-0"
            onClick={() => setExpanded(!expanded)}>
            {expanded ? "Show less" : `Show ${total - initialLimit} more`}
          </Button>
        )}
      </div>
    </div>
  );
}
