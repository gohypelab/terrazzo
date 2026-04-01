import React from "react";

import { Input } from "terrazzo/ui";
import { Label } from "terrazzo/ui";

export function TextInputFormField({ type = "text", value, label, input, required, defaultValue, ...inputProps }) {
  const resolvedDefault = defaultValue !== undefined ? defaultValue : String(value ?? "");

  return (
    <div className="space-y-2">
      {label &&
      <Label htmlFor={input?.id}>
          {label}{required && <span className="text-destructive"> *</span>}
        </Label>
      }
      <Input
        type={type}
        defaultValue={resolvedDefault}
        {...inputProps}
        {...input} />

    </div>);

}
