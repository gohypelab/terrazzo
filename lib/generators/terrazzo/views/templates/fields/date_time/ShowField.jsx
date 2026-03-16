import React from "react";

import { formatDateTime } from "terrazzo";

export function ShowField({ value }) {
  return <span>{formatDateTime(value)}</span>;
}
