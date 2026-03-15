import React from "react";
import { Badge } from "../../components/ui/badge";

export function IndexField({ value }) {
  const assoc = value;
  if (!assoc) return <span className="text-muted-foreground">-</span>;
  return <Badge variant="outline">{assoc.display}</Badge>;
}
