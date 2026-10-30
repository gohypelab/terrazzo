import React, { useEffect, useId, useState } from "react";
import { Label, Popover, PopoverContent, PopoverTrigger } from "terrazzo/ui";

export function AssociationSelect({
  value,
  options,
  input,
  label,
  required,
  multiple = false,
  onChange,
}) {
  const popupId = useId();
  const [selectedIds, setSelectedIds] = useState(() =>
    (multiple
      ? (value ?? [])
      : value == null || value === ""
        ? []
        : [value]
    ).map(String),
  );
  const [selectedOptions, setSelectedOptions] = useState(
    options.resourceOptions,
  );
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const [result, setResult] = useState({ resourceOptions: [] });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [retry, setRetry] = useState(0);

  useEffect(() => {
    if (!open) return;
    const controller = new window.AbortController();
    let active = true;
    setLoading(true);
    setError("");
    const timer = setTimeout(async () => {
      try {
        const url = new URL(options.optionsUrl, window.location.origin);
        url.searchParams.set("search", search);
        const response = await window.fetch(url, {
          headers: { Accept: "application/json" },
          signal: controller.signal,
          credentials: "same-origin",
        });
        if (!response.ok) throw new Error("Could not load options.");
        const data = await response.json();
        if (active) setResult(data);
      } catch (failure) {
        if (active && failure.name !== "AbortError")
          setError("Could not load options.");
      } finally {
        if (active) setLoading(false);
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
    const nextOptions = [
      ...selectedOptions.filter((item) => item[1] !== id),
      option,
    ].filter((item) => nextIds.includes(item[1]));
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

  return (
    <div className="space-y-2">
      {label && (
        <Label htmlFor={input?.id}>
          {label}
          {required && " *"}
        </Label>
      )}
      {input?.name && <input type="hidden" name={input.name} value="" />}
      {input?.name &&
        selectedIds.map((id) => (
          <input key={id} type="hidden" name={input.name} value={id} />
        ))}
      {multiple && (
        <div className="flex flex-wrap gap-1">
          {selectedOptions
            .filter((option) => selectedIds.includes(option[1]))
            .map(([display, id]) => (
              <button
                key={id}
                type="button"
                className="rounded bg-muted px-2 py-1 text-sm"
                aria-label={`Remove ${display}`}
                onClick={() => remove(id)}
              >
                {display} ×
              </button>
            ))}
        </div>
      )}
      <Popover
        open={open}
        onOpenChange={(next) => {
          setOpen(next);
          if (next) setLoading(true);
        }}
      >
        <PopoverTrigger asChild>
          <button
            type="button"
            id={input?.id}
            aria-describedby={input?.["aria-describedby"]}
            role="combobox"
            aria-expanded={open}
            aria-controls={popupId}
            aria-haspopup="dialog"
            className="flex min-h-10 w-full items-center rounded-md border px-3 py-2 text-sm"
          >
            {multiple
              ? "Select items…"
              : (selectedOptions.find(
                  (option) => option[1] === selectedIds[0],
                )?.[0] ?? "Select…")}
          </button>
        </PopoverTrigger>
        <PopoverContent id={popupId} className="w-80 space-y-2">
          <input
            aria-label={`Search ${label ?? "options"}`}
            value={search}
            placeholder="Search…"
            className="w-full rounded border px-2 py-1"
            onChange={(event) => {
              setSearch(event.target.value);
              setLoading(true);
            }}
          />
          {loading ? (
            <p role="status">Loading…</p>
          ) : error ? (
            <div role="alert">
              {error}{" "}
              <button
                type="button"
                onClick={() => setRetry((count) => count + 1)}
              >
                Retry
              </button>
            </div>
          ) : (
            <div
              className="max-h-60 overflow-y-auto"
              role="group"
              aria-label="Options"
            >
              {result.resourceOptions.length === 0 && <p>No results found.</p>}
              {result.resourceOptions.map((option) => (
                <button
                  key={option[1]}
                  type="button"
                  aria-pressed={selectedIds.includes(option[1])}
                  className="block w-full rounded px-2 py-1 text-left hover:bg-muted"
                  onClick={() => select(option)}
                >
                  {selectedIds.includes(option[1]) ? "✓ " : ""}
                  {option[0]}
                </button>
              ))}
            </div>
          )}
        </PopoverContent>
      </Popover>
      {!multiple && selectedIds.length > 0 && (
        <button
          type="button"
          className="text-sm text-muted-foreground"
          onClick={() => remove(selectedIds[0])}
        >
          Clear selection
        </button>
      )}
    </div>
  );
}
