import React from "react";

import { TextInputFormField } from "../shared/TextInputFormField";

export function FormField(props) {
  return <TextInputFormField type="url" {...props} />;
}
