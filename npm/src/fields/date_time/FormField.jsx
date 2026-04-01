import React from "react";

import { TextInputFormField } from "../shared/TextInputFormField";

export function FormField({ value, ...props }) {
  const defaultValue = value ? String(value).slice(0, 16) : "";
  return <TextInputFormField type="datetime-local" defaultValue={defaultValue} {...props} />;
}
