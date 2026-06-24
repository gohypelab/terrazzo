import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { getLayout } from "terrazzo";
import { SearchBar, CollectionFilters, Pagination, CollectionToolbarActions } from "../components";
import { Button, Badge } from "../components/ui";
import { CustomerCollection } from "./_collection";

export default function CustomerIndex() {
  const Layout = getLayout();
  const {
    table,
    searchBar,
    filters,
    pagination,
    toolbarActions,
    emptyState,
    navigation,
    newResourcePath,
    resourceName,
    singularResourceName
  } = useContent();

  return (
    <Layout
      navigation={navigation}
      title={resourceName}
      actions={
        <div className="flex flex-wrap items-center gap-2">
          <Badge data-testid="customer-count" variant="secondary">
            {table.rows.length} shown
          </Badge>
          <CollectionToolbarActions actions={toolbarActions} />
          {newResourcePath && (
            <a href={newResourcePath} data-sg-visit>
              <Button size="sm">New {singularResourceName}</Button>
            </a>
          )}
        </div>
      }
    >
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <SearchBar {...searchBar} />
        <CollectionFilters {...filters} />
      </div>

      <CustomerCollection table={table} emptyState={emptyState} />

      <Pagination {...pagination} />
    </Layout>
  );
}
