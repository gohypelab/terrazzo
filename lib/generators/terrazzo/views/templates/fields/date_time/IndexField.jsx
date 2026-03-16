import React from "react";

import { formatDateTime } from "terrazzo";

export function IndexField({ value }) {
  return <span className="text-sm">{formatDateTime(value)}</span>;
}
