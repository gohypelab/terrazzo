import React, { useState } from "react";

import { Label } from "terrazzo/ui";

export function FormField({ value, label, input, options, required }) {
  const groupedOptions = options?.groupedOptions ?? {};
  const polyValue = value;
  const inputProps = input;
  const typeName = inputProps?.typeName;

  const [selectedType, setSelectedType] = useState(polyValue?.type ?? "");
  const [selectedId, setSelectedId] = useState(polyValue?.id != null ? String(polyValue.id) : "");

  const filteredItems = selectedType ? groupedOptions[selectedType] ?? [] : [];

  const { typeName: _typeName, ...idInputProps } = inputProps ?? {};

  return (
    <div className="space-y-2">
      {label &&
      <Label>
          {label}{required && <span className="text-destructive"> *</span>}
        </Label>
      }
      <div className="grid grid-cols-2 gap-2">
        <select
          name={typeName}
          value={selectedType}
          onChange={(e) => {
            setSelectedType(e.target.value);
            setSelectedId("");
          }}
          className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm">

          <option value="">Select type...</option>
          {Object.keys(groupedOptions).map((className) =>
          <option key={className} value={className}>
              {className}
            </option>
          )}
        </select>
        <select
          value={selectedId}
          onChange={(e) => setSelectedId(e.target.value)}
          className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
          {...idInputProps}>

          <option value="">Select...</option>
          {filteredItems.map(([display, id]) =>
          <option key={id} value={id}>
              {display}
            </option>
          )}
        </select>
      </div>
    </div>);

}
