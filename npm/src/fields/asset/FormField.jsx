import React from "react";

import { Label, Input } from "terrazzo/ui";

export function FormField({ value, label, input, required }) {
  return (
    <div className="space-y-2">
      {label && <Label htmlFor={input?.id}>{label}{required && <span> *</span>}</Label>}
      {value?.filename && (
        <p className="text-sm text-muted-foreground">Current: {value.filename}</p>
      )}
      <Input type="file" {...input} />
    </div>
  );
}
