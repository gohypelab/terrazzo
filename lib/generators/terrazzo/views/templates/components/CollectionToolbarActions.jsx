import React from "react";

import { Button } from "./ui";
import { csrfToken } from "terrazzo";

export function CollectionToolbarActions({ actions, selectedIds, disabled = false }) {
  if (!actions || actions.length === 0) return null;
  const selectedValues = Array.isArray(selectedIds) ? selectedIds : null;

  return actions.map((action, index) => {
    const method = String(action.method || "get").toLowerCase();
    const rendersSelectedIds = selectedValues !== null;

    if (method !== "get" || rendersSelectedIds) {
      const isDestructive = method === "delete";
      const variant = action.variant || (isDestructive ? "destructive" : "outline");
      const formMethod = method === "get" ? "get" : "post";
      const selectedParamName = action.paramName || action.param_name || "ids[]";

      return (
        <form
          key={index}
          action={action.url}
          method={formMethod}
          {...(action.sg_visit !== false && { "data-sg-visit": true })}
          onSubmit={(e) => {
            if (action.confirm && !window.confirm(action.confirm)) {
              e.preventDefault();
            }
          }}
        >
          {method !== "get" && method !== "post" && (
            <input type="hidden" name="_method" value={method} />
          )}
          {method !== "get" && (
            <input
              type="hidden"
              name="authenticity_token"
              value={csrfToken()}
            />
          )}
          {selectedValues?.map((id) => (
            <input key={id} type="hidden" name={selectedParamName} value={id} />
          ))}
          <Button type="submit" variant={variant} size="sm" disabled={disabled}>
            {action.label}
          </Button>
        </form>
      );
    }

    return (
      <Button key={index} asChild variant={action.variant || "outline"} size="sm">
        <a href={action.url} {...(action.sg_visit !== false && { "data-sg-visit": true })}>
          {action.label}
        </a>
      </Button>
    );
  });
}
