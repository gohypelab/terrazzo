import React from "react";

import { formatTime } from "super-admin";

export function ShowField({ value }) {
  return <span>{formatTime(value)}</span>;
}
