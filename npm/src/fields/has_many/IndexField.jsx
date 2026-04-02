import React from "react";

import { Badge } from "terrazzo/ui";

export function IndexField({ value }) {
  const count = value?.count ?? 0;
  const label = value?.label ?? "";
  return <Badge variant="secondary">{count} {label}</Badge>;
}
