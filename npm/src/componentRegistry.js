const registryKey = "__terrazzoComponentRegistry"
const componentMap = globalThis[registryKey] || (globalThis[registryKey] = {})

export function registerComponent(name, Component) {
  componentMap[name] = Component
}

export function getComponent(name) {
  return componentMap[name]
}
