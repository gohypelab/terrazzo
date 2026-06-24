import React from "react";
import { MoreHorizontal } from "lucide-react";

import {
  Button,
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "./ui";
import { csrfToken } from "terrazzo";

export function CollectionItemActions({ actions }) {
  if (!actions || actions.length === 0) return null;

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="icon" className="h-8 w-8" aria-label="Open row actions">
          <MoreHorizontal className="h-4 w-4" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
      {actions.map((action, index) => {
        const method = String(action.method || "get").toLowerCase();

        if (method !== "get") {
          const isDestructive = method === "delete";
          return (
            <DropdownMenuItem key={index} asChild>
              <form
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
                <button type="submit" className={`w-full text-left ${isDestructive ? "text-destructive" : ""}`}>
                  {action.label}
                </button>
              </form>
            </DropdownMenuItem>
          );
        }

        return (
          <DropdownMenuItem key={index} asChild>
            <a href={action.url} {...(action.sg_visit !== false && { "data-sg-visit": true })}>
              {action.label}
            </a>
          </DropdownMenuItem>
        );
      })}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
