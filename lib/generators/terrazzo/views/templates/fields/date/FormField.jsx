import React from "react";

import { TextInputFormField } from "../shared/TextInputFormField";

export function FormField({ value, ...props }) {
  const defaultValue = value ? String(value).split("T")[0] : "";
  return <TextInputFormField type="date" defaultValue={defaultValue} {...props} />;
}
