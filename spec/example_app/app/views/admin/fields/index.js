// Re-export all fields from the terrazzo package.
// To customize a field, run: rails g terrazzo:eject fields/<field_type>
export * from "terrazzo/fields";

// String - ejected
import { registerFieldType as registerStringFieldType } from "terrazzo/fields";
import { IndexField as StringIndexField } from "./string/IndexField";
import { ShowField as StringShowField } from "./string/ShowField";
import { FormField as StringFormField } from "./string/FormField";

registerStringFieldType("string", {
  index: StringIndexField,
  show: StringShowField,
  form: StringFormField,
});

export { StringIndexField, StringShowField, StringFormField };

// Email - ejected
import { registerFieldType as registerEmailFieldType } from "terrazzo/fields";
import { IndexField as EmailIndexField } from "./email/IndexField";
import { ShowField as EmailShowField } from "./email/ShowField";
import { FormField as EmailFormField } from "./email/FormField";

registerEmailFieldType("email", {
  index: EmailIndexField,
  show: EmailShowField,
  form: EmailFormField,
});

export { EmailIndexField, EmailShowField, EmailFormField };

// Boolean - ejected
import { registerFieldType as registerBooleanFieldType } from "terrazzo/fields";
import { IndexField as BooleanIndexField } from "./boolean/IndexField";
import { ShowField as BooleanShowField } from "./boolean/ShowField";
import { FormField as BooleanFormField } from "./boolean/FormField";

registerBooleanFieldType("boolean", {
  index: BooleanIndexField,
  show: BooleanShowField,
  form: BooleanFormField,
});

export { BooleanIndexField, BooleanShowField, BooleanFormField };
