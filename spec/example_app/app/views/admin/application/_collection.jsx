import React from "react";

import { ResourceTable } from "../components";

export function AdminCollection({ table, emptyState }) {
  return (
    <div className="overflow-x-auto">
      <ResourceTable headers={table.headers} rows={table.rows} emptyState={emptyState} />
    </div>
  );
}
