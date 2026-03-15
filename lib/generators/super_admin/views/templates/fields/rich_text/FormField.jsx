import React from "react";

import { Textarea } from "../../components/ui/textarea";
import { Label } from "../../components/ui/label";

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
        rows={6}
        {...input} />

    </div>);

}
