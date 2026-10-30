import { Command } from "cmdk";
import { Check, ChevronsUpDown, Loader2, Search, X } from "lucide-react";
import React, { useEffect, useId, useState } from "react";
import { cn } from "terrazzo";
import { Label, Popover, PopoverContent, PopoverTrigger } from "./ui";

export function AssociationSelect({ value, options, input, label, required, multiple = false, onChange }) {
  const popupId = useId();
  const searchRef = React.useRef(null);
  const [selectedIds, setSelectedIds] = useState(() =>
    (multiple ? (value ?? []) : value == null || value === "" ? [] : [value]).map(String)
  );
  const [selectedOptions, setSelectedOptions] = useState(options.resourceOptions);
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const [result, setResult] = useState(null);
  const [activeResultId, setActiveResultId] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [retry, setRetry] = useState(0);
  const selected = selectedOptions.filter((option) => selectedIds.includes(option[1]));
  const placeholder = `Select ${label?.toLowerCase() ?? (multiple ? "items" : "an option")}…`;

  useEffect(() => {
    if (!open) return;
    const controller = new window.AbortController();
    let active = true;
    setLoading(true);
    const timer = setTimeout(async () => {
      try {
        const url = new URL(options.optionsUrl, window.location.origin);
        url.searchParams.set("search", search);
        const response = await window.fetch(url, {
          headers: { Accept: "application/json" },
          signal: controller.signal,
          credentials: "same-origin"
        });
        if (!response.ok) throw new Error("Could not load options.");
        const data = await response.json();
        if (active) {
          setResult(data);
          setActiveResultId(data.resourceOptions[0]?.[1] ?? "");
          setError("");
        }
      } catch (failure) {
        if (active && failure.name !== "AbortError") setError("Could not load options.");
      } finally {
        if (active) {
          setLoading(false);
        }
      }
    }, 200);
    return () => {
      active = false;
      clearTimeout(timer);
      controller.abort();
    };
  }, [open, search, options.optionsUrl, retry]);

  const select = (option) => {
    const id = option[1];
    const nextIds = multiple
      ? selectedIds.includes(id)
        ? selectedIds.filter((item) => item !== id)
        : [...selectedIds, id]
      : [id];
    const nextOptions = [...selectedOptions.filter((item) => item[1] !== id), option].filter((item) =>
      nextIds.includes(item[1])
    );
    setSelectedIds(nextIds);
    setSelectedOptions(nextOptions);
    onChange?.(multiple ? nextIds : id, option);
    if (!multiple) setOpen(false);
  };

  const remove = (id) => {
    const nextIds = selectedIds.filter((item) => item !== id);
    setSelectedIds(nextIds);
    setSelectedOptions((items) => items.filter((item) => item[1] !== id));
    onChange?.(multiple ? nextIds : "", null);
  };

  const changeOpen = (next) => {
    setOpen(next);
    if (next) {
      setLoading(true);
    }
  };

  return (
    <div className="space-y-2">
      {label && (
        <Label htmlFor={input?.id}>
          {label}
          {required && <span className="text-destructive ml-1">*</span>}
        </Label>
      )}
      {input?.name && <input type="hidden" name={input.name} value="" />}
      {input?.name && selectedIds.map((id) => <input key={id} type="hidden" name={input.name} value={id} />)}
      <Popover open={open} onOpenChange={changeOpen}>
        <div
          className={cn(
            "border-border bg-background text-foreground relative flex min-h-10 w-full items-center rounded-md border px-3 py-2 text-sm shadow-sm transition-colors",
            "hover:border-ring/50 focus-within:border-ring focus-within:ring-ring/20 focus-within:ring-2",
            open && "border-ring ring-ring/20 ring-2"
          )}
        >
          <PopoverTrigger asChild>
            <button
              type="button"
              id={input?.id}
              data-slot="association-trigger"
              aria-describedby={input?.["aria-describedby"]}
              aria-label={label ?? "Select options"}
              role="combobox"
              aria-expanded={open}
              aria-controls={popupId}
              aria-haspopup="dialog"
              className="absolute inset-0 w-full cursor-pointer rounded-md outline-none"
              onKeyDown={(event) => {
                if (event.key === "ArrowDown" || event.key === "ArrowUp") {
                  event.preventDefault();
                  changeOpen(true);
                }
              }}
            >
              <span className="sr-only">
                {selected.length ? selected.map(([name]) => name).join(", ") : placeholder}
              </span>
            </button>
          </PopoverTrigger>
          <div
            className={cn(
              "pointer-events-none flex min-w-0 flex-1 flex-wrap items-center gap-1.5 pr-6",
              !multiple && selected.length > 0 && "pr-12"
            )}
          >
            {selected.length === 0 ? (
              <span className="text-muted-foreground truncate">{placeholder}</span>
            ) : multiple ? (
              selected.map(([display, id]) => (
                <span
                  key={id}
                  className="border-border/60 bg-secondary text-secondary-foreground relative inline-flex max-w-full items-center gap-1 rounded border py-0.5 pl-2 pr-1 text-xs font-medium"
                >
                  <span className="truncate">{display}</span>
                  <button
                    type="button"
                    aria-label={`Remove ${display}`}
                    className="text-muted-foreground hover:bg-foreground/10 hover:text-foreground focus-visible:ring-ring pointer-events-auto relative z-10 inline-flex size-5 shrink-0 cursor-pointer items-center justify-center rounded-sm outline-none focus-visible:ring-2"
                    onClick={() => remove(id)}
                  >
                    <X className="size-3" aria-hidden="true" />
                  </button>
                </span>
              ))
            ) : (
              <span className="truncate">{selected[0][0]}</span>
            )}
          </div>
          {!multiple && selected.length > 0 && (
            <button
              type="button"
              aria-label={`Clear ${label ?? "selection"}`}
              className="text-muted-foreground hover:bg-accent hover:text-accent-foreground focus-visible:ring-ring absolute right-8 z-10 inline-flex size-6 cursor-pointer items-center justify-center rounded-sm outline-none focus-visible:ring-2"
              onClick={() => remove(selectedIds[0])}
            >
              <X className="size-3.5" aria-hidden="true" />
            </button>
          )}
          <ChevronsUpDown
            className="text-muted-foreground pointer-events-none absolute right-3 size-4"
            aria-hidden="true"
          />
        </div>
        <PopoverContent
          id={popupId}
          align="start"
          sideOffset={6}
          className="border-border bg-popover text-popover-foreground w-[var(--radix-popover-trigger-width)] max-w-[calc(100vw-2rem)] overflow-hidden rounded-lg p-0 shadow-lg"
          onOpenAutoFocus={(event) => {
            event.preventDefault();
            searchRef.current?.focus();
          }}
        >
          <Command
            shouldFilter={false}
            loop
            value={activeResultId}
            onValueChange={setActiveResultId}
            label={`Search ${label ?? "options"}`}
            className="bg-popover text-popover-foreground flex w-full flex-col overflow-hidden"
          >
            <div className="border-border flex items-center gap-2.5 border-b px-3">
              <span
                data-slot="association-search-indicator"
                className="text-muted-foreground relative size-4 shrink-0"
                aria-hidden="true"
              >
                {loading ? <Loader2 className="size-4 animate-spin" /> : <Search className="size-4" />}
              </span>
              <Command.Input
                ref={searchRef}
                data-slot="association-search"
                type="text"
                aria-label={`Search ${label ?? "options"}`}
                value={search}
                placeholder={`Search ${label?.toLowerCase() ?? "options"}…`}
                className="bg-transparent! text-popover-foreground placeholder:text-muted-foreground h-11 min-w-0 flex-1 border-0 px-0 text-sm shadow-none outline-none focus:border-0 focus:outline-none focus:ring-0"
                onValueChange={(text) => {
                  setSearch(text);
                  setLoading(true);
                }}
              />
            </div>
            <span role="status" className="sr-only">
              {loading ? "Searching…" : ""}
            </span>
            <Command.List
              className="max-h-64 min-h-20 scroll-py-1 overflow-y-auto overflow-x-hidden p-1"
              aria-busy={loading}
            >
              {error ? (
                <div role="alert" className="text-muted-foreground space-y-2 px-3 py-5 text-center text-sm">
                  <p>{error}</p>
                  <button
                    type="button"
                    className="text-foreground focus-visible:ring-ring rounded px-2 py-1 font-medium underline underline-offset-4 outline-none focus-visible:ring-2"
                    disabled={loading}
                    onClick={() => {
                      setLoading(true);
                      setRetry((count) => count + 1);
                    }}
                  >
                    Try again
                  </button>
                </div>
              ) : result ? (
                <>
                  {result.resourceOptions.length === 0 && (
                    <p className="text-muted-foreground px-3 py-6 text-center text-sm">No results found.</p>
                  )}
                  {result.resourceOptions.map((option) => (
                    <Command.Item
                      key={option[1]}
                      value={option[1]}
                      aria-label={option[0]}
                      aria-checked={selectedIds.includes(option[1])}
                      disabled={loading}
                      onSelect={() => select(option)}
                      className="data-[selected=true]:bg-accent data-[selected=true]:text-accent-foreground relative flex min-h-9 cursor-pointer select-none items-center gap-2 rounded-md px-2.5 py-2 text-sm outline-none"
                    >
                      <span className="min-w-0 flex-1 truncate">{option[0]}</span>
                      <Check
                        className={cn(
                          "size-4 shrink-0",
                          selectedIds.includes(option[1]) ? "text-primary" : "opacity-0"
                        )}
                        aria-hidden="true"
                      />
                    </Command.Item>
                  ))}
                </>
              ) : null}
            </Command.List>
          </Command>
        </PopoverContent>
      </Popover>
    </div>
  );
}
