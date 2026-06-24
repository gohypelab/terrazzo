import React from "react";

export function ShowField({ value }) {
  return <span>{String(value ?? "")}</span>;
}
