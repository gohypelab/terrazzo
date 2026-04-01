import React from "react";

import { Textarea } from "terrazzo/ui";
import { Label } from "terrazzo/ui";

export function FormField({ value, label, input, required }) {
  return (
    <div className="space-y-2">
      {label &&
      <Label htmlFor={input?.id}>
          {label}{required && <span className="text-destructive"> *</span>}
        </Label>
      }
      <Textarea
        defaultValue={String(value ?? "")}
        {...input} />

    </div>);

}
