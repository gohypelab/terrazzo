import React from "react";

import { Label } from "terrazzo/ui";

export function FormField({ value, label, input, required }) {
  return (
    <div className="flex items-center space-x-2">
      <input
        type="checkbox"
        defaultChecked={!!value}
        className="h-4 w-4 rounded border-gray-300"
        {...input} />

      {label &&
      <Label htmlFor={input?.id}>
          {label}{required && <span className="text-destructive"> *</span>}
        </Label>
      }
    </div>);

}
