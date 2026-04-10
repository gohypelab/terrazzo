import React, { useState } from "react";

import { ResourceTable } from "terrazzo/components";
import { Badge } from "terrazzo/ui";
import { Button } from "terrazzo/ui";

function buildOffsetUrl(attribute, newOffset) {
  var url = new URL(window.location.href);
  if (newOffset > 0) {
    url.searchParams.set("offsets[" + attribute + "]", newOffset);
  } else {
    url.searchParams.delete("offsets[" + attribute + "]");
  }
  return url.pathname + url.search;
}

function PaginationControls({ attribute, offset, limit, total }) {
  var hasPrev = offset > 0;
  var hasNext = offset + limit < total;
  var showing = Math.min(limit, total - offset);
  var start = offset + 1;
  var end = offset + showing;

  return (
    <div className="mt-2 flex items-center gap-3">
      <span className="text-sm text-muted-foreground">
        {start}–{end} of {total}
      </span>
      <div className="flex gap-1">
        <Button
          variant="outline"
          size="sm"
          disabled={!hasPrev}
          {...(hasPrev ? { "data-sg-visit": true, "data-sg-placeholder": "/admin" } : {})}
          asChild={hasPrev}>
          {hasPrev ? (
            <a href={buildOffsetUrl(attribute, Math.max(0, offset - limit))}>Previous</a>
          ) : (
            "Previous"
          )}
        </Button>
        <Button
          variant="outline"
          size="sm"
          disabled={!hasNext}
          {...(hasNext ? { "data-sg-visit": true, "data-sg-placeholder": "/admin" } : {})}
          asChild={hasNext}>
          {hasNext ? (
            <a href={buildOffsetUrl(attribute, offset + limit)}>Next</a>
          ) : (
            "Next"
          )}
        </Button>
      </div>
    </div>
  );
}

export function ShowField({ value, hasManyRowExtras, options, attribute }) {
  if (!value) return <span className="text-muted-foreground">None</span>;

  const { rows, headers, total, initialLimit, offset, items } = value;
  const [expanded, setExpanded] = useState(false);
  const currentOffset = offset || 0;

  // Table mode: collection_attributes specified
  if (headers && rows) {
    if (rows.length === 0 && total === 0) {
      return <span className="text-muted-foreground">None</span>;
    }

    const allLoaded = total <= initialLimit;
    const hasMore = initialLimit && initialLimit > 0 && total > initialLimit;
    const visibleRows = expanded && allLoaded ? rows : rows;

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
        <ResourceTable headers={headers} rows={enrichedRows} showActions={options?.renderActions !== false} />
        {hasMore && (
          allLoaded ? (
            <Button
              variant="link"
              size="sm"
              className="mt-2 px-0"
              onClick={() => setExpanded(!expanded)}>
              {expanded ? "Show less" : `Show ${total - initialLimit} more`}
            </Button>
          ) : (
            <PaginationControls
              attribute={attribute}
              offset={currentOffset}
              limit={initialLimit}
              total={total}
            />
          )
        )}
      </div>
    );
  }

  // Simple list mode (no collection_attributes)
  if (!items || (items.length === 0 && total === 0)) {
    return <span className="text-muted-foreground">None</span>;
  }

  const allLoaded = total <= initialLimit;
  const hasMore = initialLimit && initialLimit > 0 && total > initialLimit;
  const visibleItems = expanded && allLoaded ? items : items;

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
      </div>
      {hasMore && (
        allLoaded ? (
          <Button
            variant="link"
            size="sm"
            className="px-0"
            onClick={() => setExpanded(!expanded)}>
            {expanded ? "Show less" : `Show ${total - initialLimit} more`}
          </Button>
        ) : (
          <PaginationControls
            attribute={attribute}
            offset={currentOffset}
            limit={initialLimit}
            total={total}
          />
        )
      )}
    </div>
  );
}
