import React from "react";

import { formatDate } from "super-admin";

export function IndexField({ value }) {
  return <span className="text-sm">{formatDate(value)}</span>;
}
