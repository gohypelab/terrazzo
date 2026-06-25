import React from "react";

import { ResourceTable } from "../components";

export function AdminCollection({ table, emptyState, bulkActions = [] }) {
  return (
    <div className="overflow-x-auto">
      <ResourceTable
        headers={table.headers}
        rows={table.rows}
        emptyState={emptyState}
        bulkActions={bulkActions}
      />
    </div>
  );
}
