import React from "react";

import { FieldRenderer } from "terrazzo/fields";
import { Button } from "terrazzo/ui";

export function AdminForm({ form = {}, errors = [] }) {
  const { props: formProps = {}, extras = {}, fieldGroups = [], fields = [] } = form;
  const groups = Array.isArray(fieldGroups) ? fieldGroups : [];
  const hasFieldGroups = groups.length > 0;

  const renderField = (field) => {
    const hintId = field.hint && field.input?.id ? `${field.input.id}_hint` : null;
    const input = hintId ?
      { ...field.input, "aria-describedby": hintId } :
      field.input;

    return (
      <div key={field.attribute} className="space-y-2">
        <FieldRenderer
          mode="form"
          fieldType={field.fieldType}
          value={field.value}
          options={field.options}
          attribute={field.attribute}
          label={field.label}
          hint={field.hint}
          input={input}
          required={field.required} />
        {field.hint && (
          <p id={hintId ?? undefined} className="text-sm text-muted-foreground">
            {field.hint}
          </p>
        )}
      </div>
    );
  };

  return (
    <>
      {errors.length > 0 &&
      <div className="rounded-md border border-red-200 bg-red-50 p-4 mb-6">
          <h3 className="text-sm font-medium text-red-800 mb-2">
            {errors.length} {errors.length === 1 ? "error" : "errors"} prevented this record from being saved:
          </h3>
          <ul className="list-disc pl-5 space-y-1">
            {errors.map((error, i) =>
          <li key={i} className="text-sm text-red-700">{error}</li>
          )}
          </ul>
        </div>
      }

      <form {...formProps} data-sg-visit>
        {Object.values(extras).map((hiddenProps) =>
        <input key={hiddenProps.name} {...hiddenProps} />
        )}

        {hasFieldGroups ? (
          <div className="space-y-8">
            {groups.map((group, groupIndex) =>
              <fieldset key={groupIndex} className="space-y-6">
                {group.name && (
                  <legend className="text-lg font-semibold">{group.name}</legend>
                )}
                <div className="space-y-6">
                  {(group.fields || []).map((field) => renderField(field))}
                </div>
              </fieldset>
            )}
          </div>
        ) : (
          <div className="space-y-6">
            {fields.map((field) => renderField(field))}
          </div>
        )}

        <div className="mt-6 flex gap-2">
          <Button type="submit">Save</Button>
        </div>
      </form>
    </>);

}
