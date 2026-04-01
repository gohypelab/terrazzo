import React, { useState, useRef, useEffect } from "react";

import { Input } from "terrazzo/ui";
import { Button } from "terrazzo/ui";
import { Label } from "terrazzo/ui";

export function FormField({ value, label, input, options, required }) {
  const initialPairs = () => {
    if (value && typeof value === "object" && Object.keys(value).length > 0) {
      return Object.entries(value).map(([k, v], i) => ({ id: i, key: k, value: v ?? "" }));
    }
    return [{ id: 0, key: "", value: "" }];
  };

  const [pairs, setPairs] = useState(initialPairs);
  const nextId = useRef(pairs.length);

  const addPair = () => {
    setPairs((prev) => [...prev, { id: nextId.current++, key: "", value: "" }]);
  };

  const removePair = (id) => {
    setPairs((prev) => {
      const updated = prev.filter((p) => p.id !== id);
      return updated.length === 0 ? [{ id: nextId.current++, key: "", value: "" }] : updated;
    });
  };

  const updatePair = (id, field, val) => {
    setPairs((prev) =>
      prev.map((p) => (p.id === id ? { ...p, [field]: val } : p))
    );
  };

  const serialized = () => {
    const obj = {};
    for (const p of pairs) {
      const k = p.key.trim();
      if (k) obj[k] = p.value;
    }
    return JSON.stringify(obj);
  };

  return (
    <div className="space-y-2">
      {label && (
        <Label htmlFor={input?.id}>
          {label}
          {required && <span className="text-destructive"> *</span>}
        </Label>
      )}
      <input type="hidden" name={input?.name} value={serialized()} />
      <div className="space-y-2">
        {pairs.map((pair) => (
          <div key={pair.id} className="flex items-center gap-2">
            <Input
              type="text"
              placeholder="Key"
              value={pair.key}
              onChange={(e) => updatePair(pair.id, "key", e.target.value)}
              className="flex-1 font-mono text-sm"
            />
            <Input
              type="text"
              placeholder="Value"
              value={pair.value}
              onChange={(e) => updatePair(pair.id, "value", e.target.value)}
              className="flex-1 text-sm"
            />
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => removePair(pair.id)}
              className="shrink-0 text-muted-foreground hover:text-destructive"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <path d="M18 6 6 18" />
                <path d="m6 6 12 12" />
              </svg>
            </Button>
          </div>
        ))}
      </div>
      <Button
        type="button"
        variant="outline"
        size="sm"
        onClick={addPair}
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="16"
          height="16"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          className="mr-1"
        >
          <path d="M5 12h14" />
          <path d="M12 5v14" />
        </svg>
        Add pair
      </Button>
    </div>
  );
}
