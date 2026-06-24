import AdminIndex from "../../views/admin/application/index";
import AdminShow from "../../views/admin/application/show";
import AdminNew from "../../views/admin/application/new";
import AdminEdit from "../../views/admin/application/edit";
import { generatedPageMapping } from "./generated_page_mapping";
import { customPageMapping } from "./custom_page_mapping";

const applicationPages = {
  'admin/application/index': AdminIndex,
  'admin/application/show': AdminShow,
  'admin/application/new': AdminNew,
  'admin/application/edit': AdminEdit,
}

const pages = {
  ...applicationPages,
  ...generatedPageMapping,
  ...customPageMapping,
}

// Resolves resource-specific page identifiers (e.g. "admin/orders/index")
// with fallback to the shared application component (e.g. "admin/application/index").
export const pageToPageMapping = new Proxy(pages, {
  get(target, prop) {
    if (prop in target) return target[prop]
    if (typeof prop === "string") {
      const action = prop.split("/").pop()
      const fallback = "admin/application/" + action
      if (fallback in target) return target[fallback]
    }
    return undefined
  }
})
