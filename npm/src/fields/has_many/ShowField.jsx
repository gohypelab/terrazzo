import React from "react";
import { ResourceTable, HasManyPagination } from "terrazzo/components";
import { Badge } from "terrazzo/ui";

export function ShowField({ value, hasManyRowExtras, paginationPaths, options }) {
  if (!value) return <span className="text-muted-foreground">None</span>;

  const { rows, headers, items, total, currentPage, totalPages } = value;

  const pagination = (
    <HasManyPagination
      currentPage={currentPage}
      totalPages={totalPages}
      total={total}
      nextPagePath={paginationPaths?.nextPagePath}
      prevPagePath={paginationPaths?.prevPagePath}
    />
  );

  // Table mode: collection_attributes specified
  if (headers && rows) {
    if (rows.length === 0 && total === 0) {
      return <span className="text-muted-foreground">None</span>;
    }

    const enrichedRows = rows.map((row) => {
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
        {pagination}
      </div>
    );
  }

  // Simple list mode (no collection_attributes)
  if ((!items || items.length === 0) && total === 0) {
    return <span className="text-muted-foreground">None</span>;
  }

  return (
    <div>
      <div className="flex flex-wrap items-center gap-1.5">
        {(items || []).map((item) => {
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
      {pagination}
    </div>
  );
}
