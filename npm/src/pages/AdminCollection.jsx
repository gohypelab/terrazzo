import React from "react";

import { getComponent } from "../componentRegistry";
import { ResourceTable as DefaultResourceTable } from "../components/ResourceTable";

export function AdminCollection({ table, emptyState }) {
  const ResourceTable = getComponent("ResourceTable") || DefaultResourceTable;

  return (
    <div className="overflow-x-auto">
      <ResourceTable headers={table.headers} rows={table.rows} emptyState={emptyState} />
    </div>
  );
}
