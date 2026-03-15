import React from "react";

import { Input } from "../../components/ui/input";
import { Label } from "../../components/ui/label";

export function FormField({ label, input, required }) {
  return (
    <div className="space-y-2">
      {label &&
      <Label htmlFor={input?.id}>
          {label}{required && <span className="text-destructive"> *</span>}
        </Label>
      }
      <Input
        type="password"
        {...input} />

    </div>);

}
