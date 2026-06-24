import { configureStore } from "@reduxjs/toolkit"
import { flashSlice } from "./slices/flash"
import {
  beforeVisit,
  beforeFetch,
  beforeRemote,
  rootReducer,
} from "@thoughtbot/superglue"

const { pages, superglue } = rootReducer

export const store = configureStore({
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
