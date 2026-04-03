import React, { useContext } from "react";
import { useContent, NavigationContext } from "@thoughtbot/superglue";

import { Layout, SearchBar, Pagination, SortableHeader, CollectionItemActions } from "terrazzo/components";
import { FieldRenderer } from "terrazzo/fields";
import { Button, Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "terrazzo/ui";

export default function AdminIndex() {
  const { visit } = useContext(NavigationContext);
  const {
    table,
    searchBar,
    pagination,
    navigation,
    newResourcePath,
    resourceName,
    singularResourceName
  } = useContent();

  const handleRowClick = (e, showPath) => {
    if (!showPath) return;
    if (e.target.closest("a, button, form")) return;
    if (window.getSelection().toString()) return;
    visit(showPath, {});
  };

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

      <div className="overflow-x-auto rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              {table.headers.map((header) =>
              <SortableHeader key={header.attribute} {...header} />
              )}
              <TableHead className="w-[120px]">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {table.rows.map((row) =>
            <TableRow
              key={row.id}
              className={row.showPath ? "cursor-pointer" : ""}
              onClick={(e) => handleRowClick(e, row.showPath)}>
                {row.cells.map((cell) =>
              <TableCell key={cell.attribute}>
                    {cell.showPath ? (
                      <a href={cell.showPath} data-sg-visit className="hover:underline">
                        <FieldRenderer mode="index" {...cell} />
                      </a>
                    ) : (
                      <FieldRenderer mode="index" {...cell} />
                    )}
                  </TableCell>
              )}
                <TableCell>
                  <CollectionItemActions actions={row.collectionItemActions} />
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      <Pagination {...pagination} />
    </Layout>);

}
