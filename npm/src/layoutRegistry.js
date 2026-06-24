import { Layout as DefaultLayout } from "./components/Layout"

const registryKey = "__terrazzoLayoutRegistry"
const layoutRegistry = globalThis[registryKey] || (globalThis[registryKey] = {})

export function setLayout(LayoutComponent) {
  layoutRegistry.Component = LayoutComponent
}

export function getLayout() {
  return layoutRegistry.Component || DefaultLayout
}
