import React from "react";

import { Badge } from "terrazzo/ui";

export function IndexField({ value }) {
  if (value == null || value === "") {
    return <span className="text-muted-foreground">-</span>;
  }

  return (
    <span className="text-sm text-muted-foreground truncate block max-w-[300px]">
      {value}
    </span>
  );
}
