import React from "react";
import { TextInputFormField } from "../shared/TextInputFormField";

export function FormField(props) {
  return <TextInputFormField type="text" data-testid="custom-string-form-field" {...props} />;
}
