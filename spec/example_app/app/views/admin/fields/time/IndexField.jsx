import React from "react";

import { formatTime } from "super-admin";

export function IndexField({ value }) {
  return <span className="text-sm">{formatTime(value)}</span>;
}
