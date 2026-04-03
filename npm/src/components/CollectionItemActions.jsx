import React from "react";
import { Button } from "terrazzo/ui";

export function CollectionItemActions({ actions }) {
  if (!actions || actions.length === 0) return null;

  return (
    <div className="flex gap-1">
      {actions.map((action, index) => {
        if (action.method === "delete") {
          return (
            <form
              key={index}
              action={action.url}
              method="post"
              data-sg-visit
              style={{ display: "inline" }}
              onSubmit={(e) => {
                if (action.confirm && !window.confirm(action.confirm)) {
                  e.preventDefault();
                }
              }}
            >
              <input type="hidden" name="_method" value="delete" />
              <input
                type="hidden"
                name="authenticity_token"
                value={document.querySelector('meta[name="csrf-token"]')?.content ?? ""}
              />
              <Button type="submit" variant="ghost" size="sm" className="text-destructive">
                {action.label}
              </Button>
            </form>
          );
        }

        return (
          <a key={index} href={action.url} data-sg-visit>
            <Button variant="ghost" size="sm">{action.label}</Button>
          </a>
        );
      })}
    </div>
  );
}
