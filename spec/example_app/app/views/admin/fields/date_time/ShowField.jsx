import React from "react";

import { formatDateTime } from "super-admin";

export function ShowField({ value }) {
  return <span>{formatDateTime(value)}</span>;
}
