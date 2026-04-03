import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { Layout, SearchBar, Pagination } from "../components";
import { AdminCollection } from "./_collection";
import { Button } from "../components/ui";

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
