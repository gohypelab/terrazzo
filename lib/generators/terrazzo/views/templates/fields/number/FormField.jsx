import React from "react";

import { TextInputFormField } from "../shared/TextInputFormField";

export function FormField({ value, options, ...props }) {
  const step = options?.decimals ? `0.${"0".repeat(options.decimals - 1)}1` : "any";
  const defaultValue = value != null ? String(value) : "";
  return <TextInputFormField type="number" step={step} defaultValue={defaultValue} {...props} />;
}
