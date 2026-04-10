import React from "react";
import { Button } from "terrazzo/ui";
import { ChevronLeft, ChevronRight } from "lucide-react";

export function HasManyPagination({ currentPage, totalPages, total, nextPagePath, prevPagePath }) {
  if (totalPages <= 1) return null;
  return (
    <div className="flex items-center justify-between gap-2 pt-2 text-sm text-muted-foreground">
      <span>Page {currentPage} of {totalPages} &middot; {total} total</span>
      <div className="flex items-center gap-1">
        {prevPagePath ? (
          <Button asChild variant="outline" size="sm">
            <a href={prevPagePath} data-sg-visit><ChevronLeft className="h-4 w-4" /> Prev</a>
          </Button>
        ) : (
          <Button variant="outline" size="sm" disabled><ChevronLeft className="h-4 w-4" /> Prev</Button>
        )}
        {nextPagePath ? (
          <Button asChild variant="outline" size="sm">
            <a href={nextPagePath} data-sg-visit>Next <ChevronRight className="h-4 w-4" /></a>
          </Button>
        ) : (
          <Button variant="outline" size="sm" disabled>Next <ChevronRight className="h-4 w-4" /></Button>
        )}
      </div>
    </div>
  );
}
