import React from "react"
import { createRoot } from "react-dom/client"
import { Application } from "@thoughtbot/superglue"
import { configureStore } from "@reduxjs/toolkit"
import {
  beforeVisit,
  beforeFetch,
  beforeRemote,
  rootReducer,
} from "@thoughtbot/superglue"
import { buildVisitAndRemote } from "./application_visit"
import { pageToPageMapping } from "./page_to_page_mapping"
import { flashSlice } from "./slices/flash"

const { pages, superglue } = rootReducer

const store = configureStore({
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: [beforeFetch.type, beforeVisit.type, beforeRemote.type],
      },
    }),
  reducer: {
    superglue,
    pages,
    flash: flashSlice.reducer,
  },
})

document.addEventListener("DOMContentLoaded", () => {
  const appEl = document.getElementById("superglue-app")
  if (!appEl) return

  const location = window.location

  const root = createRoot(appEl)
  root.render(
    <Application
      baseUrl={location.origin}
      initialPage={window.SUPERGLUE_INITIAL_PAGE_STATE}
      path={location.pathname + location.search + location.hash}
      buildVisitAndRemote={buildVisitAndRemote}
      store={store}
      mapping={pageToPageMapping}
    />
  )
})
