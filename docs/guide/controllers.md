# Controllers

SuperAdmin generates a base `ApplicationController` for your admin namespace. All resource controllers inherit from it.

## Authentication

Add a `before_action` to protect your admin:

```ruby
# app/controllers/admin/application_controller.rb
class Admin::ApplicationController < SuperAdmin::ApplicationController
  before_action :authenticate_admin

  private

  def authenticate_admin
    redirect_to root_path unless current_user&.admin?
  end
end
```

## Scoping Records

Override `scoped_resource` to limit which records are visible:

```ruby
def scoped_resource
  if current_user.admin?
    resource_class.all
  else
    resource_class.where(user: current_user)
  end
end
```

## Authorization

Override `authorized_action?` to control access to specific actions:

```ruby
def authorized_action?(resource, action)
  current_user.can?(action, resource)
end
```

When this returns `false`, SuperAdmin raises `SuperAdmin::NotAuthorizedError`.

## Per-Resource Controllers

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

## How It Works

`SuperAdmin::ApplicationController` provides standard CRUD actions:

- **index** — paginated, searchable, sortable list
- **show** — single record detail
- **new / create** — new record form and creation
- **edit / update** — edit form and update
- **destroy** — record deletion

Create and update use `redirect_to` on success (Superglue handles redirects as SPA navigations). On validation failure, the form is re-rendered with `status: :unprocessable_entity`.
