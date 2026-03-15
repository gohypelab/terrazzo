import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs) {
  return twMerge(clsx(inputs));
}

export function truncate(str, length = 50) {
  if (!str) return "";
  return str.length > length ? str.slice(0, length) + "..." : str;
}

export function formatDate(value) {
  if (!value) return "";
  return new Date(value).toLocaleDateString();
}

export function formatDateTime(value) {
  if (!value) return "";
  return new Date(value).toLocaleString();
}

export function formatTime(value) {
  if (!value) return "";
  return new Date(value).toLocaleTimeString();
}
