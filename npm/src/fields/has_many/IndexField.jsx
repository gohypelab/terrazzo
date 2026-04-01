import React from "react";

import { Badge } from "terrazzo/ui";

export function IndexField({ value }) {
  const count = typeof value === "number" ? value : 0;
  return <Badge variant="secondary">{count}</Badge>;
}
