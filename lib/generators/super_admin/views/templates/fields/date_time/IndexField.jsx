import React from "react";

import { formatDateTime } from "super-admin";

export function IndexField({ value }) {
  return <span className="text-sm">{formatDateTime(value)}</span>;
}
