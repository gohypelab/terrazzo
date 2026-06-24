import React from "react";

export function IndexField({ value }) {
  return <span className="text-sm">{value ?? "\u2014"}</span>;
}
