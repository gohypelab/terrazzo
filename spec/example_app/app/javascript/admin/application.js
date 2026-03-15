import React from "react"
import { createRoot } from "react-dom/client"
import { Application, rootReducer, prepareStore } from "@thoughtbot/superglue"
import { configureStore } from "@reduxjs/toolkit"
import { buildVisitAndRemote } from "./application_visit"
import { pageToPageMapping } from "./page_to_page_mapping"
import { flashSlice } from "./slices/flash"

function initApp() {
  const appEl = document.getElementById("superglue-app")
  const initialPage = window.SUPERGLUE_INITIAL_PAGE_STATE
  if (!appEl || !initialPage) return

  const path = window.location.pathname + window.location.search + window.location.hash

  const store = configureStore({
    reducer: {
      ...rootReducer,
      flash: flashSlice.reducer,
    },
  })
  prepareStore(store, initialPage, path)

  const root = createRoot(appEl)
  root.render(
    <Application
      initialPage={initialPage}
      baseUrl={window.location.origin}
      path={path}
      store={store}
      mapping={pageToPageMapping}
      buildVisitAndRemote={buildVisitAndRemote}
    />
  )
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initApp)
} else {
  initApp()
}
