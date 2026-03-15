# Views & Components

All generated views and components live in your app at `app/views/admin/` and can be edited directly.

## File Structure

```
app/views/admin/
├── application/
│   ├── index.jsx      # list view
│   ├── show.jsx       # detail view
│   ├── new.jsx        # new form
│   ├── edit.jsx       # edit form
│   └── _form.jsx      # shared form partial
├── components/
│   ├── ui/            # shadcn UI primitives
│   ├── Layout.jsx     # main layout wrapper
│   ├── SearchBar.jsx
│   └── ...
└── fields/
    ├── string/        # each field type has Index, Show, and Form variants
    ├── boolean/
    └── ...
```

## Overriding Views Per Resource

To customize a page for a specific resource, create a view at that resource's path:

```
app/views/admin/products/index.jsx    → overrides the products index page
app/views/admin/products/show.jsx     → overrides the products show page
```

Your custom component receives the same props as the default:

```jsx
// app/views/admin/products/index.jsx
import { useContent } from "@thoughtbot/superglue"
import { Layout } from "../components/Layout"

export default function ProductsIndex() {
  const { table, searchBar, pagination, navigation } = useContent()
  return (
    <Layout navigation={navigation} title="Products">
      {/* your custom layout */}
    </Layout>
  )
}
```

## Re-generating Views

To reset all generated components to their defaults (e.g., after upgrading the gem):

```bash
rails g super_admin:views
```

This will overwrite your local copies with the latest versions from the gem.

## SPA Navigation

SuperAdmin uses [Superglue](https://github.com/thoughtbot/superglue) for client-side navigation:

- **Full navigation** — links with `data-sg-visit` trigger a full page transition (e.g., sidebar links, show/edit links)
- **Partial updates** — links with `data-sg-remote` update only part of the page (e.g., search, sort, pagination)

Pagination and sort links include `props_at` parameters so the server only renders the relevant subtrees, keeping updates fast.
