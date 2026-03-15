import React from "react";

import { formatDate } from "super-admin";

export function ShowField({ value }) {
  return <span>{formatDate(value)}</span>;
}
