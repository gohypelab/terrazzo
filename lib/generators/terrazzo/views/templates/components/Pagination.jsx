import React, { useContext } from "react";
import { NavigationContext } from "@thoughtbot/superglue";

import { Field, FieldLabel } from "./ui";
import {
  Pagination as PaginationRoot,
  PaginationContent,
  PaginationItem,
  PaginationNext,
  PaginationPrevious,
} from "./ui";
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "./ui";

export function Pagination({ currentPage, totalPages, totalCount, perPage, nextPagePath, prevPagePath }) {
  const { visit } = useContext(NavigationContext);
  const page = Math.max(Number(currentPage) || 1, 1);
  const pages = Math.max(Number(totalPages) || 1, 1);
  const count = Math.max(Number(totalCount) || 0, 0);

  const handlePerPageChange = (value) => {
    const url = new URL(window.location.href);
    url.searchParams.set("per_page", value);
    url.searchParams.delete("_page");
    visit(url.pathname + url.search, {});
  };

  return (
    <div className="flex flex-col gap-3 py-4 sm:flex-row sm:items-center sm:justify-between">
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:gap-4">
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
        <p className="text-sm text-muted-foreground" aria-live="polite">
          Page {page} of {pages} - {count.toLocaleString()} total
        </p>
      </div>
      <PaginationRoot className="mx-0 w-auto">
        <PaginationContent>
          <PaginationItem>
            {prevPagePath ? (
              <PaginationPrevious href={prevPagePath} data-sg-visit />
            ) : (
              <PaginationPrevious className="pointer-events-none opacity-50" />
            )}
          </PaginationItem>
          <PaginationItem>
            {nextPagePath ? (
              <PaginationNext href={nextPagePath} data-sg-visit />
            ) : (
              <PaginationNext className="pointer-events-none opacity-50" />
            )}
          </PaginationItem>
        </PaginationContent>
      </PaginationRoot>
    </div>
  );
}
