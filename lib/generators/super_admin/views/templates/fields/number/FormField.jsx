import React from "react";

import { Input } from "../../components/ui/input";
import { Label } from "../../components/ui/label";

export function FormField({ value, label, input, options, required }) {
  const step = options?.decimals ? `0.${"0".repeat(options.decimals - 1)}1` : "any";

  return (
    <div className="space-y-2">
      {label &&
      <Label htmlFor={input?.id}>
          {label}{required && <span className="text-destructive"> *</span>}
        </Label>
      }
      <Input
        type="number"
        step={step}
        defaultValue={value != null ? String(value) : ""}
        {...input} />

    </div>);

}
