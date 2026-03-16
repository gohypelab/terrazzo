import React from "react";

import { formatTime } from "terrazzo";

export function IndexField({ value }) {
  return <span className="text-sm">{formatTime(value)}</span>;
}
