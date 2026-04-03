# Authorization

Terrazzo provides hooks for controlling which records a user can see and which actions they can perform.

## Scoping Records

Override `scoped_resource` to limit which records are visible. This applies to all actions (index, show, edit, destroy):

```ruby
# app/controllers/admin/application_controller.rb
class Admin::ApplicationController < Terrazzo::ApplicationController
  private

  def scoped_resource
    if current_user.admin?
      resource_class.all
    else
      resource_class.where(user: current_user)
    end
  end
end
```

You can also scope per-resource:

```ruby
# app/controllers/admin/orders_controller.rb
class Admin::OrdersController < Admin::ApplicationController
  private

  def scoped_resource
    current_user.orders
  end
end
```

## Authorizing Actions

Override `authorized_action?` to control access to specific actions:

```ruby
# app/controllers/admin/application_controller.rb
class Admin::ApplicationController < Terrazzo::ApplicationController
  private

  def authorized_action?(resource, action)
    current_user.can?(action, resource)
  end
end
```

When this returns `false`, Terrazzo raises `Terrazzo::NotAuthorizedError`.

## Using Pundit

If you use [Pundit](https://github.com/varvet/pundit), integrate it through the authorization hooks:

```ruby
class Admin::ApplicationController < Terrazzo::ApplicationController
  include Pundit::Authorization

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  private

  def scoped_resource
    policy_scope(resource_class)
  end

  def authorized_action?(resource, action)
    authorize(resource, :"#{action}?")
    true
  rescue Pundit::NotAuthorizedError
    false
  end
end
```

## Hiding Actions Per Resource

To hide certain actions (e.g., prevent deletion), exclude them from routes:

```ruby
# config/routes.rb
namespace :admin do
  resources :orders, except: [:destroy]
  resources :countries, only: [:index, :show]
end
```

Terrazzo automatically hides action buttons (New, Edit, Delete) when their routes don't exist.
