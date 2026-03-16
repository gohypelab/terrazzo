import React from "react";

import { formatDate } from "terrazzo";

export function ShowField({ value }) {
  return <span>{formatDate(value)}</span>;
}
