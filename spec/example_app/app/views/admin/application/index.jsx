import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { getLayout } from "terrazzo";
import { SearchBar, CollectionFilters, Pagination, CollectionToolbarActions } from "../components";
import { AdminCollection } from "./_collection";
import { Button } from "../components/ui";

export default function AdminIndex() {
  const Layout = getLayout();
  const {
    table,
    searchBar,
    filters,
    pagination,
    layoutActions,
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
          <CollectionToolbarActions actions={layoutActions} />
          <CollectionToolbarActions actions={toolbarActions} />
          {newResourcePath && (
            <a href={newResourcePath} data-sg-visit>
              <Button size="sm">New {singularResourceName}</Button>
            </a>
          )}
        </div>
      }>

      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <SearchBar {...searchBar} />
        <CollectionFilters {...filters} />
      </div>

      <AdminCollection table={table} emptyState={emptyState} />

      <Pagination {...pagination} />
    </Layout>);

}
