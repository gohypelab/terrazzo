import React from "react";

import { Button } from "./ui";

export function CollectionFilters({ active, allUrl, options }) {
  if (!options || options.length === 0) return null;

  return (
    <div className="flex flex-wrap items-center gap-2">
      <Button asChild variant={active ? "outline" : "secondary"} size="sm">
        <a href={allUrl} data-sg-visit>All</a>
      </Button>
      {options.map((option) => (
        <Button
          key={option.value}
          asChild
          variant={option.active ? "secondary" : "outline"}
          size="sm"
        >
          <a href={option.url} data-sg-visit>{option.label}</a>
        </Button>
      ))}
    </div>
  );
}
