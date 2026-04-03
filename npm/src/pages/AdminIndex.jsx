import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { Layout, SearchBar, Pagination } from "terrazzo/components";
import { AdminCollection } from "./AdminCollection";
import { Button } from "terrazzo/ui";

export default function AdminIndex() {
  const {
    table,
    searchBar,
    pagination,
    navigation,
    newResourcePath,
    resourceName,
    singularResourceName
  } = useContent();

  return (
    <Layout
      navigation={navigation}
      title={resourceName}
      actions={newResourcePath &&
      <a href={newResourcePath} data-sg-visit>
          <Button size="sm">New {singularResourceName}</Button>
        </a>
      }>

      <div className="flex items-center">
        <SearchBar {...searchBar} />
      </div>

      <AdminCollection table={table} />

      <Pagination {...pagination} />
    </Layout>);

}
