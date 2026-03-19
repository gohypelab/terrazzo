import React from "react";
import { ChevronUp, ChevronDown, ChevronsUpDown } from "lucide-react";

import { TableHead } from "./ui/table";

export function SortableHeader({ label, sortable, sortUrl, sortDirection }) {
  if (!sortable) {
    return <TableHead>{label}</TableHead>;
  }

  return (
    <TableHead>
      <a
        href={sortUrl}
        data-sg-remote
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
