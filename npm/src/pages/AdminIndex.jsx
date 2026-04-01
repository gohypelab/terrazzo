import React, { useContext } from "react";
import { useContent, NavigationContext } from "@thoughtbot/superglue";

import { Layout, SearchBar, Pagination, SortableHeader } from "terrazzo/components";
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
      actions={
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
                  <div className="flex gap-1">
                    {row.showPath &&
                  <a href={row.showPath} data-sg-visit>
                        <Button variant="ghost" size="sm">Show</Button>
                      </a>
                  }
                    {row.editPath &&
                  <a href={row.editPath} data-sg-visit>
                        <Button variant="ghost" size="sm">Edit</Button>
                      </a>
                  }
                    {row.deletePath &&
                  <form
                    action={row.deletePath}
                    method="post"
                    data-sg-visit
                    style={{ display: "inline" }}
                    onSubmit={(e) => {
                      if (!window.confirm("Are you sure?")) e.preventDefault();
                    }}>

                        <input type="hidden" name="_method" value="delete" />
                        <input
                      type="hidden"
                      name="authenticity_token"
                      value={document.querySelector('meta[name="csrf-token"]')?.content ?? ""} />

                        <Button type="submit" variant="ghost" size="sm" className="text-destructive">
                          Delete
                        </Button>
                      </form>
                  }
                  </div>
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      <Pagination {...pagination} />
    </Layout>);

}
