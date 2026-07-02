# Customizing Controller Actions

Terrazzo generates a base `ApplicationController` for your admin namespace. All resource controllers inherit from it.

For authentication and authorization, see the dedicated [Authentication](./authentication) and [Authorization](./authorization) pages.

## Customizing Actions

Each dashboard generator creates a resource-specific controller:

```ruby
# app/controllers/admin/products_controller.rb
class Admin::ProductsController < Admin::ApplicationController
end
```

You can override any CRUD action here:

```ruby
class Admin::ProductsController < Admin::ApplicationController
  def create
    # custom create logic
    super
  end

  private

  def scoped_resource
    Product.where(active: true)
  end
end
```

## Customizing `find_resource`

Terrazzo's generated admin links use each record's `to_param`, so a model that overrides `to_param` (for example, to expose a slug) automatically gets slug-based admin URLs. When `to_param` returns something other than the primary key, you must override `find_resource` to match, or those generated links will 404:

```ruby
class Admin::ProductsController < Admin::ApplicationController
  private

  def find_resource(id)
    scoped_resource.find_by!(slug: id)
  end
end
```

`find_resource` defaults to a primary-key lookup (`scoped_resource.find(id)`), so no override is needed when `to_param` returns the id.

## Pagination Limits

Index pages show 25 rows by default and clamp `per_page` query params to 100 rows. Override `default_per_page` or `max_per_page` in an admin controller when a resource needs a different limit:

```ruby
class Admin::ProductsController < Admin::ApplicationController
  private

  def default_per_page
    50
  end

  def max_per_page
    200
  end
end
```

## How It Works

`Terrazzo::ApplicationController` provides standard CRUD actions:

- **index** — paginated, searchable, sortable list
- **show** — single record detail
- **new / create** — new record form and creation
- **edit / update** — edit form and update
- **destroy** — record deletion

Create and update use `redirect_to` on success (Superglue handles redirects as SPA navigations). On validation failure, the form is re-rendered with `status: :unprocessable_entity`.

## Superglue Template Lookup

Terrazzo uses Superglue to render React pages server-side. When a controller has a long view prefix chain (e.g. from Devise or other engine-mounted controllers), Superglue's template existence check can accidentally match a gem-supplied HTML template and render it instead of the React page.

Terrazzo automatically scopes the template lookup to your app's `app/views` directory only, so gem templates are never used as a fallback.
