import { visit, remote } from "@thoughtbot/superglue/action_creators"

export const buildVisitAndRemote = (ref, store) => {
  const appRemote = (path, { dataset, ...options }) => {
    return store.dispatch(remote(path, options))
  }

  const appVisit = (path, { dataset, ...options } = {}) => {
    return store
      .dispatch(visit(path, options))
      .then((meta) => {
        if (meta.needsRefresh) {
          window.location.href = meta.pageKey
          return meta
        }

        const navigationAction = !!dataset?.sgReplace
          ? "replace"
          : meta.navigationAction
        ref.current?.navigateTo(meta.pageKey, {
          action: navigationAction,
        })

        return meta
      })
      .catch((err) => {
        const response = err.response

        if (!response) {
          console.error(err)
          return
        }

        if (response.ok) {
          window.location = response.url
        } else {
          if (response.status >= 400 && response.status < 500) {
            window.location.href = "/400.html"
            return
          }
          if (response.status >= 500) {
            window.location.href = "/500.html"
            return
          }
        }
      })
  }

  return { visit: appVisit, remote: appRemote }
}
