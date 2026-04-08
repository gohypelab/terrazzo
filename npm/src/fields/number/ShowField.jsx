import React from "react";

export function ShowField({ value, options }) {
  const prefix = options?.prefix ?? "";
  const suffix = options?.suffix ?? "";
  const decimals = options?.decimals;
  const formatted = decimals != null && value != null ? Number(value).toFixed(decimals) : String(value ?? "");
  return <span className="tabular-nums">{prefix}{formatted}{suffix && ` ${suffix}`}</span>;
}
