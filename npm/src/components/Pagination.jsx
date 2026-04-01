import React, { useContext } from "react";
import { NavigationContext } from "@thoughtbot/superglue";

import { Field, FieldLabel } from "terrazzo/ui";
import {
  Pagination as PaginationRoot,
  PaginationContent,
  PaginationItem,
  PaginationNext,
  PaginationPrevious,
} from "terrazzo/ui";
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "terrazzo/ui";

export function Pagination({ currentPage, totalPages, totalCount, perPage, nextPagePath, prevPagePath }) {
  const { remote, pageKey } = useContext(NavigationContext);

  const handlePerPageChange = (value) => {
    const url = new URL(window.location.href);
    url.searchParams.set("per_page", value);
    url.searchParams.delete("_page");
    remote(url.pathname + url.search, { pageKey });
  };

  return (
    <div className="flex items-center justify-between gap-4 py-4">
      <Field orientation="horizontal" className="w-fit">
        <FieldLabel htmlFor="select-rows-per-page">Rows per page</FieldLabel>
        <Select value={String(perPage)} onValueChange={handlePerPageChange}>
          <SelectTrigger className="w-20" id="select-rows-per-page">
            <SelectValue />
          </SelectTrigger>
          <SelectContent align="start">
            <SelectGroup>
              <SelectItem value="10">10</SelectItem>
              <SelectItem value="25">25</SelectItem>
              <SelectItem value="50">50</SelectItem>
              <SelectItem value="100">100</SelectItem>
            </SelectGroup>
          </SelectContent>
        </Select>
      </Field>
      <PaginationRoot className="mx-0 w-auto">
        <PaginationContent>
          <PaginationItem>
            {prevPagePath ? (
              <PaginationPrevious href={prevPagePath} data-sg-remote />
            ) : (
              <PaginationPrevious className="pointer-events-none opacity-50" />
            )}
          </PaginationItem>
          <PaginationItem>
            {nextPagePath ? (
              <PaginationNext href={nextPagePath} data-sg-remote />
            ) : (
              <PaginationNext className="pointer-events-none opacity-50" />
            )}
          </PaginationItem>
        </PaginationContent>
      </PaginationRoot>
    </div>
  );
}
