import React from "react";

import { IndexField as StringIndex } from "./string/IndexField";
import { ShowField as StringShow } from "./string/ShowField";
import { FormField as StringForm } from "./string/FormField";

import { IndexField as TextIndex } from "./text/IndexField";
import { ShowField as TextShow } from "./text/ShowField";
import { FormField as TextForm } from "./text/FormField";

import { IndexField as NumberIndex } from "./number/IndexField";
import { ShowField as NumberShow } from "./number/ShowField";
import { FormField as NumberForm } from "./number/FormField";

import { IndexField as BooleanIndex } from "./boolean/IndexField";
import { ShowField as BooleanShow } from "./boolean/ShowField";
import { FormField as BooleanForm } from "./boolean/FormField";

import { IndexField as DateIndex } from "./date/IndexField";
import { ShowField as DateShow } from "./date/ShowField";
import { FormField as DateForm } from "./date/FormField";

import { IndexField as DateTimeIndex } from "./date_time/IndexField";
import { ShowField as DateTimeShow } from "./date_time/ShowField";
import { FormField as DateTimeForm } from "./date_time/FormField";

import { IndexField as TimeIndex } from "./time/IndexField";
import { ShowField as TimeShow } from "./time/ShowField";
import { FormField as TimeForm } from "./time/FormField";

import { IndexField as EmailIndex } from "./email/IndexField";
import { ShowField as EmailShow } from "./email/ShowField";
import { FormField as EmailForm } from "./email/FormField";

import { IndexField as UrlIndex } from "./url/IndexField";
import { ShowField as UrlShow } from "./url/ShowField";
import { FormField as UrlForm } from "./url/FormField";

import { IndexField as PasswordIndex } from "./password/IndexField";
import { ShowField as PasswordShow } from "./password/ShowField";
import { FormField as PasswordForm } from "./password/FormField";

import { IndexField as SelectIndex } from "./select/IndexField";
import { ShowField as SelectShow } from "./select/ShowField";
import { FormField as SelectForm } from "./select/FormField";

import { IndexField as RichTextIndex } from "./rich_text/IndexField";
import { ShowField as RichTextShow } from "./rich_text/ShowField";
import { FormField as RichTextForm } from "./rich_text/FormField";

import { IndexField as BelongsToIndex } from "./belongs_to/IndexField";
import { ShowField as BelongsToShow } from "./belongs_to/ShowField";
import { FormField as BelongsToForm } from "./belongs_to/FormField";

import { IndexField as HasManyIndex } from "./has_many/IndexField";
import { ShowField as HasManyShow } from "./has_many/ShowField";
import { FormField as HasManyForm } from "./has_many/FormField";

import { IndexField as HasOneIndex } from "./has_one/IndexField";
import { ShowField as HasOneShow } from "./has_one/ShowField";
import { FormField as HasOneForm } from "./has_one/FormField";

import { IndexField as PolymorphicIndex } from "./polymorphic/IndexField";
import { ShowField as PolymorphicShow } from "./polymorphic/ShowField";
import { FormField as PolymorphicForm } from "./polymorphic/FormField";

const fieldMap = {
  string: { index: StringIndex, show: StringShow, form: StringForm },
  text: { index: TextIndex, show: TextShow, form: TextForm },
  number: { index: NumberIndex, show: NumberShow, form: NumberForm },
  boolean: { index: BooleanIndex, show: BooleanShow, form: BooleanForm },
  date: { index: DateIndex, show: DateShow, form: DateForm },
  date_time: { index: DateTimeIndex, show: DateTimeShow, form: DateTimeForm },
  time: { index: TimeIndex, show: TimeShow, form: TimeForm },
  email: { index: EmailIndex, show: EmailShow, form: EmailForm },
  url: { index: UrlIndex, show: UrlShow, form: UrlForm },
  password: { index: PasswordIndex, show: PasswordShow, form: PasswordForm },
  select: { index: SelectIndex, show: SelectShow, form: SelectForm },
  rich_text: { index: RichTextIndex, show: RichTextShow, form: RichTextForm },
  belongs_to: { index: BelongsToIndex, show: BelongsToShow, form: BelongsToForm },
  has_many: { index: HasManyIndex, show: HasManyShow, form: HasManyForm },
  has_one: { index: HasOneIndex, show: HasOneShow, form: HasOneForm },
  polymorphic: { index: PolymorphicIndex, show: PolymorphicShow, form: PolymorphicForm }
};

// Allow consumers to register custom field components
export function registerFieldType(
fieldType,
components)
{
  fieldMap[fieldType] = { ...fieldMap[fieldType], ...components };
}

export function FieldRenderer({ mode, fieldType, ...rest }) {
  const Component = fieldMap[fieldType]?.[mode];
  if (!Component) return <span>{String(rest.value ?? "")}</span>;
  return <Component {...rest} />;
}
