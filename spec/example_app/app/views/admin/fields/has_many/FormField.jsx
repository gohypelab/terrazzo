import React, { useState, useRef, useCallback } from "react";
import { X, Check } from "lucide-react";

import { Label } from "../../components/ui/label";
import { Badge } from "../../components/ui/badge";
import { Popover, PopoverTrigger, PopoverContent } from "../../components/ui/popover";
import { cn } from "super-admin";

export function FormField({ value, label, input, options, required }) {
  const resourceOptions = options?.resourceOptions ?? [];
  const initialIds = value ?? [];

  const [selectedIds, setSelectedIds] = useState(() => new Set(initialIds));
  const [search, setSearch] = useState("");
  const [open, setOpen] = useState(false);
  const inputRef = useRef(null);

  const inputProps = input;
  const inputName = inputProps?.name;
  const inputId = inputProps?.id;

  const toggleOption = useCallback((id) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
    setSearch("");
  }, []);

  const removeOption = useCallback((id, e) => {
    e.preventDefault();
    e.stopPropagation();
    setSelectedIds((prev) => {
      const next = new Set(prev);
      next.delete(id);
      return next;
    });
  }, []);

  const selectedOptions = resourceOptions.filter(([, id]) => selectedIds.has(id));
  const filteredOptions = resourceOptions.filter(([display]) =>
  display.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-2">
      {label &&
      <Label htmlFor={inputId}>
          {label}{required && <span className="text-destructive"> *</span>}
        </Label>
      }

      {/* Hidden inputs for form submission */}
      {inputName && <input type="hidden" name={inputName} value="" />}
      {selectedIds.size > 0 && inputName &&
      Array.from(selectedIds).map((id) =>
      <input key={id} type="hidden" name={inputName} value={id} />
      )
      }

      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <button
            type="button"
            role="combobox"
            aria-expanded={open}
            id={inputId}
            className={cn(
              "flex min-h-10 w-full flex-wrap items-center gap-1 rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background",
              "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
              "hover:bg-accent/50 cursor-pointer"
            )}>

            {selectedOptions.length > 0 ?
            selectedOptions.map(([display, id]) =>
            <Badge key={id} variant="secondary" className="gap-1">
                  {display}
                  <span
                role="button"
                tabIndex={0}
                className="ml-0.5 rounded-full outline-none hover:bg-muted-foreground/20 focus:bg-muted-foreground/20"
                onPointerDown={(e) => removeOption(id, e)}
                onKeyDown={(e) => {
                  if (e.key === "Enter" || e.key === " ") {
                    e.preventDefault();
                    removeOption(id, e);
                  }
                }}>

                    <X className="h-3 w-3" />
                  </span>
                </Badge>
            ) :

            <span className="text-muted-foreground">Select {label?.toLowerCase() ?? "items"}...</span>
            }
          </button>
        </PopoverTrigger>
        <PopoverContent
          className="p-0"
          onOpenAutoFocus={(e) => {
            e.preventDefault();
            inputRef.current?.focus();
          }}>

          <div className="p-2 border-b">
            <input
              ref={inputRef}
              type="text"
              className="flex h-8 w-full rounded-md bg-transparent px-2 py-1 text-sm outline-none placeholder:text-muted-foreground"
              placeholder={`Search ${label?.toLowerCase() ?? "items"}...`}
              value={search}
              onChange={(e) => setSearch(e.target.value)} />

          </div>
          <div className="max-h-60 overflow-y-auto p-1">
            {filteredOptions.length === 0 ?
            <div className="px-2 py-4 text-center text-sm text-muted-foreground">
                No results found.
              </div> :

            filteredOptions.map(([display, id]) => {
              const isSelected = selectedIds.has(id);
              return (
                <button
                  key={id}
                  type="button"
                  className={cn(
                    "flex w-full items-center gap-2 rounded-sm px-2 py-1.5 text-sm cursor-pointer",
                    "outline-none hover:bg-accent hover:text-accent-foreground",
                    "focus:bg-accent focus:text-accent-foreground"
                  )}
                  onClick={() => toggleOption(id)}>

                    <Check className={cn("h-4 w-4 shrink-0", isSelected ? "opacity-100" : "opacity-0")} />
                    {display}
                  </button>);

            })
            }
          </div>
        </PopoverContent>
      </Popover>
    </div>);

}
