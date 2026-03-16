import React from "react"
import { createRoot } from "react-dom/client"
import { Application } from "@thoughtbot/superglue"
import { buildVisitAndRemote } from "./application_visit"
import { pageToPageMapping } from "./page_to_page_mapping"
import { store } from "./store"

if (typeof window !== "undefined") {
  document.addEventListener("DOMContentLoaded", function () {
    const appEl = document.getElementById("superglue-app")
    const location = window.location

    if (appEl) {
      const root = createRoot(appEl)
      root.render(
        <Application
          initialPage={window.SUPERGLUE_INITIAL_PAGE_STATE}
          baseUrl={location.origin}
          path={location.pathname + location.search + location.hash}
          store={store}
          mapping={pageToPageMapping}
          buildVisitAndRemote={buildVisitAndRemote}
        />
      )
    }
  })
}
