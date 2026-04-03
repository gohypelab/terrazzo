# Authentication

Terrazzo doesn't ship with built-in authentication. Protect your admin by adding a `before_action` to the generated `ApplicationController`.

## Using Devise

```ruby
# app/controllers/admin/application_controller.rb
class Admin::ApplicationController < Terrazzo::ApplicationController
  before_action :authenticate_admin_user!

  private

  def authenticate_admin_user!
    redirect_to main_app.root_path unless current_user&.admin?
  end
end
```

## Using Clearance

```ruby
# app/controllers/admin/application_controller.rb
class Admin::ApplicationController < Terrazzo::ApplicationController
  before_action :require_login
  before_action :require_admin

  private

  def require_admin
    deny_access unless current_user&.admin?
  end
end
```

## Using HTTP Basic Authentication

```ruby
# app/controllers/admin/application_controller.rb
class Admin::ApplicationController < Terrazzo::ApplicationController
  http_basic_authenticate_with(
    name: Rails.application.credentials.admin_name,
    password: Rails.application.credentials.admin_password,
  )
end
```

## Using OmniAuth or Custom Auth

Any authentication system works — just add the appropriate `before_action` to your admin `ApplicationController`. The key is to prevent unauthenticated access before any Terrazzo action runs.
