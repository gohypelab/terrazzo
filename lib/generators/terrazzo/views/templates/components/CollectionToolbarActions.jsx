import React from "react";

import { Button } from "./ui";
import { csrfToken } from "terrazzo";

export function CollectionToolbarActions({ actions }) {
  if (!actions || actions.length === 0) return null;

  return actions.map((action, index) => {
    const method = String(action.method || "get").toLowerCase();

    if (method !== "get") {
      const isDestructive = method === "delete";
      const variant = action.variant || (isDestructive ? "destructive" : "outline");
      return (
        <form
          key={index}
          action={action.url}
          method="post"
          {...(action.sg_visit !== false && { "data-sg-visit": true })}
          onSubmit={(e) => {
            if (action.confirm && !window.confirm(action.confirm)) {
              e.preventDefault();
            }
          }}
        >
          {method !== "post" && (
            <input type="hidden" name="_method" value={method} />
          )}
          <input
            type="hidden"
            name="authenticity_token"
            value={csrfToken()}
          />
          <Button type="submit" variant={variant} size="sm">
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
