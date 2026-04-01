import * as React from "react"

import { cn } from "terrazzo"

const Field = React.forwardRef(({ className, orientation = "vertical", ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      "flex gap-2",
      orientation === "horizontal" ? "flex-row items-center" : "flex-col",
      className
    )}
    {...props} />
))
Field.displayName = "Field"

const FieldLabel = React.forwardRef(({ className, ...props }, ref) => (
  <label
    ref={ref}
    className={cn(
      "text-sm font-medium text-muted-foreground whitespace-nowrap",
      className
    )}
    {...props} />
))
FieldLabel.displayName = "FieldLabel"

export { Field, FieldLabel }
