import React from "react";

export function ShowField({ value }) {
  const items = value?.items ?? [];
  if (items.length === 0) return <span className="text-muted-foreground">None</span>;
  return (
    <ul className="list-disc pl-5 space-y-1">
      {items.map((item) =>
      <li key={item.id}>{item.display}</li>
      )}
    </ul>);

}
