import React, { useState } from "react";

import { ResourceTable } from "terrazzo/components";
import { Badge } from "terrazzo/ui";
import { Button } from "terrazzo/ui";

export function ShowField({ value, hasManyRowExtras }) {
  if (!value) return <span className="text-muted-foreground">None</span>;

  const { rows, headers, total, initialLimit, items } = value;
  const [expanded, setExpanded] = useState(false);

  // Table mode: collection_attributes specified
  if (headers && rows) {
    if (rows.length === 0) {
      return <span className="text-muted-foreground">None</span>;
    }

    const hasMore = initialLimit && initialLimit > 0 && total > initialLimit;
    const visibleRows = expanded || !hasMore ? rows : rows.slice(0, initialLimit);

    const enrichedRows = visibleRows.map((row) => {
      const extras = hasManyRowExtras?.[String(row.id)] || {};
      return {
        ...row,
        showPath: extras.showPath,
        collectionItemActions: extras.collectionItemActions,
      };
    });

    return (
      <div>
        <ResourceTable headers={headers} rows={enrichedRows} />
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

  // Simple list mode (no collection_attributes)
  if (!items || items.length === 0) {
    return <span className="text-muted-foreground">None</span>;
  }

  const hasMore = initialLimit && initialLimit > 0 && total > initialLimit;
  const visibleItems = expanded || !hasMore ? items : items.slice(0, initialLimit);

  return (
    <div>
      <div className="flex flex-wrap items-center gap-1.5">
        {visibleItems.map((item) => {
          const showPath = hasManyRowExtras?.[String(item.id)]?.showPath;
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
