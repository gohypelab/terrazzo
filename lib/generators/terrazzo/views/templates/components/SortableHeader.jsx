import React from "react";
import { ArrowUp, ArrowDown, ArrowUpDown } from "lucide-react";

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
        <ArrowUp className="h-4 w-4" /> :
        sortDirection === "desc" ?
        <ArrowDown className="h-4 w-4" /> :

        <ArrowUpDown className="h-4 w-4" />
        }
      </a>
    </TableHead>);

}
