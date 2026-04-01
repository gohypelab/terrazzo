import React from "react";

import { formatTime } from "terrazzo";

export function ShowField({ value }) {
  return <span>{formatTime(value)}</span>;
}
