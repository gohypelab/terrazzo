import React from "react";

import { Label } from "terrazzo/ui";

export function FormField({ value, label, input, options, required }) {
  const resourceOptions = options?.resourceOptions ?? [];

  return (
    <div className="space-y-2">
      {label &&
      <Label htmlFor={input?.id}>
          {label}{required && <span className="text-destructive"> *</span>}
        </Label>
      }
      <select
        defaultValue={value != null ? String(value) : ""}
        className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
        {...input}>

        <option value="">Select...</option>
        {resourceOptions.map(([display, id]) =>
        <option key={id} value={id}>
            {display}
          </option>
        )}
      </select>
    </div>);
}
