import React from "react";

import { Input } from "../../components/ui/input";
import { Label } from "../../components/ui/label";

export function FormField({ value, label, input, required }) {
  return (
    <div className="space-y-2">
      {label &&
      <Label htmlFor={input?.id}>
          {label}{required && <span className="text-destructive"> *</span>}
        </Label>
      }
      <Input
        type="url"
        defaultValue={String(value ?? "")}
        {...input} />

    </div>);

}
