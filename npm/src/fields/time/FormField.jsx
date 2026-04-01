import React from "react";

import { TextInputFormField } from "../shared/TextInputFormField";

export function FormField({ value, ...props }) {
  const defaultValue = value ? String(value) : "";
  return <TextInputFormField type="time" defaultValue={defaultValue} {...props} />;
}
