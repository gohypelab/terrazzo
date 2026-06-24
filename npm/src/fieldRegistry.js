const registryKey = "__terrazzoFieldRegistry"
const fieldMap = globalThis[registryKey] || (globalThis[registryKey] = {})

export function registerFieldType(type, components) {
  fieldMap[type] = { ...fieldMap[type], ...components }
}

export function getFieldComponent(type, mode) {
  return fieldMap[type]?.[mode]
}
