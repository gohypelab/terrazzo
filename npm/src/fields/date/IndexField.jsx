import React from "react";

import { formatDate } from "terrazzo";

export function IndexField({ value }) {
  return <span className="text-sm">{formatDate(value)}</span>;
}
