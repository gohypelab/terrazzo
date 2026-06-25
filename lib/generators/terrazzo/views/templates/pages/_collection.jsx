import React from "react";

import { ResourceTable } from "../components";

export function AdminCollection({ table = {}, emptyState, bulkActions = [] }) {
  const { headers = [], rows = [] } = table || {};

  return (
    <div className="overflow-x-auto">
      <ResourceTable headers={headers} rows={rows} emptyState={emptyState} bulkActions={bulkActions} />
    </div>
  );
}
