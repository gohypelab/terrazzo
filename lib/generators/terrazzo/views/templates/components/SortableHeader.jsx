import React from "react";
import { ChevronUp, ChevronDown, ChevronsUpDown } from "lucide-react";

import { TableHead } from "./ui";

export function SortableHeader({ label, sortable, sortUrl, sortDirection, headerOptions }) {
  const headerClassName = headerOptions?.className || headerOptions?.class_name;

  if (!sortable) {
    return <TableHead className={headerClassName}>{label}</TableHead>;
  }

  return (
    <TableHead className={headerClassName}>
      <a
        href={sortUrl}
        data-sg-visit
        className="inline-flex items-center gap-1 hover:text-foreground">

        {label}
        {sortDirection === "asc" ?
        <ChevronUp className="h-4 w-4" /> :
        sortDirection === "desc" ?
        <ChevronDown className="h-4 w-4" /> :

        <ChevronsUpDown className="h-4 w-4" />
        }
      </a>
    </TableHead>);

}
