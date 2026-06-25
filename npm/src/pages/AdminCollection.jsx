import React from "react";

import { getComponent } from "../componentRegistry";
import { ResourceTable as DefaultResourceTable } from "../components/ResourceTable";

export function AdminCollection({ table = {}, emptyState, bulkActions = [] }) {
  const ResourceTable = getComponent("ResourceTable") || DefaultResourceTable;
  const { headers = [], rows = [] } = table || {};

  return (
    <div className="overflow-x-auto">
      <ResourceTable headers={headers} rows={rows} emptyState={emptyState} bulkActions={bulkActions} />
    </div>
  );
}
