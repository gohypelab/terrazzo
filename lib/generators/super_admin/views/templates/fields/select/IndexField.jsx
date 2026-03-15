import React from "react";

import { Badge } from "../../components/ui/badge";

export function IndexField({ value }) {
  if (value == null) return <span className="text-muted-foreground">-</span>;
  return <Badge variant="secondary">{String(value)}</Badge>;
}
