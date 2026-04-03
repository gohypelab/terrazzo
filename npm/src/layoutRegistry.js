import { Layout as DefaultLayout } from "./components/Layout"

let customLayout = null

export function setLayout(LayoutComponent) {
  customLayout = LayoutComponent
}

export function getLayout() {
  return customLayout || DefaultLayout
}
