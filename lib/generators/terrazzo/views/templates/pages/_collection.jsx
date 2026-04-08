import React from "react";

import { ResourceTable } from "terrazzo/components";

export function AdminCollection({ table }) {
  return (
    <div className="overflow-x-auto">
      <ResourceTable headers={table.headers} rows={table.rows} />
    </div>
  );
}
