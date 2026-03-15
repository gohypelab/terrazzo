import React from "react";
import { useAppSelector, cn } from "super-admin";

export function FlashMessages() {
  const flash = useAppSelector((state) => state.flash);

  if (!flash || Object.keys(flash).length === 0) return null;

  return (
    <div className="mb-4 space-y-2">
      {Object.entries(flash).map(([type, message]) =>
      <div
        key={type}
        className={cn(
          "rounded-md border px-4 py-3 text-sm",
          type === "notice" && "border-green-200 bg-green-50 text-green-800",
          type === "alert" && "border-red-200 bg-red-50 text-red-800",
          type === "error" && "border-red-200 bg-red-50 text-red-800"
        )}>

          {message}
        </div>
      )}
    </div>);

}
