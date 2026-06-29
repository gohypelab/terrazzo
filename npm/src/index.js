// crypto.randomUUID is only defined in secure contexts (HTTPS, localhost). Admin
// forms depend on it (via react-hook-form's useFieldArray), so polyfill it for
// insecure origins — custom hostnames, LAN IPs, plain-HTTP dev. No-op when the
// native API is already present, so secure contexts are untouched.
if (
  typeof globalThis.crypto !== "undefined" &&
  typeof globalThis.crypto.randomUUID !== "function" &&
  typeof globalThis.crypto.getRandomValues === "function"
) {
  globalThis.crypto.randomUUID = () => {
    const bytes = globalThis.crypto.getRandomValues(new Uint8Array(16))
    bytes[6] = (bytes[6] & 0x0f) | 0x40
    bytes[8] = (bytes[8] & 0x3f) | 0x80
    const hex = Array.from(bytes, (b) => b.toString(16).padStart(2, "0"))
    return (
      hex.slice(0, 4).join("") +
      "-" +
      hex.slice(4, 6).join("") +
      "-" +
      hex.slice(6, 8).join("") +
      "-" +
      hex.slice(8, 10).join("") +
      "-" +
      hex.slice(10, 16).join("")
    )
  }
}

// Utilities
export { cn, truncate, formatDate, formatDateTime, formatTime, csrfToken } from "./utils"

// Hooks
export { useIsMobile } from "./hooks/use-mobile"

// Store
export { useAppSelector } from "./store"

// Components
export { CollectionItemActions } from "./components/CollectionItemActions"
export { registerComponent, getComponent } from "./componentRegistry"

// Field registry
export { registerFieldType, getFieldComponent } from "./fieldRegistry"

// Layout registry
export { setLayout, getLayout } from "./layoutRegistry"
