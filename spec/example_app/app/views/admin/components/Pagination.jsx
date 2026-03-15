import React from "react";

import { Button } from "./ui/button";

export function Pagination({ currentPage, totalPages, totalCount, nextPagePath, prevPagePath }) {
  if (totalPages <= 1) return null;

  return (
    <div className="flex items-center justify-between py-4">
      <p className="text-sm text-muted-foreground">
        Page {currentPage} of {totalPages} ({totalCount} total)
      </p>
      <div className="flex gap-2">
        {prevPagePath ?
        <a href={prevPagePath} data-sg-remote>
            <Button variant="outline" size="sm">Previous</Button>
          </a> :

        <Button variant="outline" size="sm" disabled>Previous</Button>
        }
        {nextPagePath ?
        <a href={nextPagePath} data-sg-remote>
            <Button variant="outline" size="sm">Next</Button>
          </a> :

        <Button variant="outline" size="sm" disabled>Next</Button>
        }
      </div>
    </div>);

}
