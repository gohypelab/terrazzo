import React from "react";

import { Badge } from "terrazzo/ui";

export function IndexField({ value }) {
  if (value == null) return <span className="text-muted-foreground">-</span>;
  return (
    <Badge variant={value ? "default" : "secondary"}>
      {value ? "Yes" : "No"}
    </Badge>);

}
