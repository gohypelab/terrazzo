import React from "react";

function formatBytes(bytes) {
  if (bytes == null || bytes === 0) return "0 B";
  const units = ["B", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  return `${(bytes / Math.pow(1024, i)).toFixed(i === 0 ? 0 : 1)} ${units[i]}`;
}

export function ShowField({ value }) {
  if (!value) return <span className="text-muted-foreground">No file</span>;
  return <span>{value.filename} ({formatBytes(value.byteSize)})</span>;
}
