import React from "react";
import { Button } from "terrazzo/ui";

export function CollectionItemActions({ actions }) {
  if (!actions || actions.length === 0) return null;

  return (
    <div className="flex gap-1">
      {actions.map((action, index) => {
        if (action.method && action.method !== "get") {
          const isDestructive = action.method === "delete";
          return (
            <form
              key={index}
              action={action.url}
              method="post"
              {...(action.sg_visit !== false && { "data-sg-visit": true })}
              style={{ display: "inline" }}
              onSubmit={(e) => {
                if (action.confirm && !window.confirm(action.confirm)) {
                  e.preventDefault();
                }
              }}
            >
              {action.method !== "post" && (
                <input type="hidden" name="_method" value={action.method} />
              )}
              <input
                type="hidden"
                name="authenticity_token"
                value={document.querySelector('meta[name="csrf-token"]')?.content ?? ""}
              />
              <Button type="submit" variant="ghost" size="sm" className={isDestructive ? "text-destructive" : ""}>
                {action.label}
              </Button>
            </form>
          );
        }

        return (
          <a key={index} href={action.url} {...(action.sg_visit !== false && { "data-sg-visit": true })}>
            <Button variant="ghost" size="sm">{action.label}</Button>
          </a>
        );
      })}
    </div>
  );
}
