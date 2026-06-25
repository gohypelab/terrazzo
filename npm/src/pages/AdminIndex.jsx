import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { getComponent } from "../componentRegistry";
import { SearchBar as DefaultSearchBar } from "../components/SearchBar";
import { CollectionFilters as DefaultCollectionFilters } from "../components/CollectionFilters";
import { Pagination as DefaultPagination } from "../components/Pagination";
import { CollectionToolbarActions as DefaultCollectionToolbarActions } from "../components/CollectionToolbarActions";
import { getLayout } from "../layoutRegistry";
import { AdminCollection } from "./AdminCollection";
import { Button } from "terrazzo/ui";

export default function AdminIndex() {
  const Layout = getLayout();
  const SearchBar = getComponent("SearchBar") || DefaultSearchBar;
  const CollectionFilters = getComponent("CollectionFilters") || DefaultCollectionFilters;
  const Pagination = getComponent("Pagination") || DefaultPagination;
  const CollectionToolbarActions = getComponent("CollectionToolbarActions") || DefaultCollectionToolbarActions;
  const {
    table,
    searchBar,
    filters,
    pagination,
    layoutActions,
    toolbarActions,
    bulkActions,
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

      <AdminCollection table={table} emptyState={emptyState} bulkActions={bulkActions} />

      <Pagination {...pagination} />
    </Layout>);

}
