import React from "react";

export function ShowField({ value }) {
  return <p className="whitespace-pre-wrap">{String(value ?? "")}</p>;
}
