require "kaminari"
require "props_template"
require "form_props"
require "super_admin/version"
require "super_admin/engine"
require "super_admin/not_authorized_error"

module SuperAdmin
  autoload :BaseDashboard, "super_admin/base_dashboard"
  autoload :ResourceResolver, "super_admin/resource_resolver"
  autoload :Search, "super_admin/search"
  autoload :Order, "super_admin/order"
  autoload :Filter, "super_admin/filter"
  autoload :Namespace, "super_admin/namespace"
  autoload :GeneratorHelpers, "super_admin/generator_helpers"

  module Field
    autoload :Base, "super_admin/field/base"
    autoload :Deferred, "super_admin/field/deferred"
    autoload :Associative, "super_admin/field/associative"
    autoload :String, "super_admin/field/string"
    autoload :Text, "super_admin/field/text"
    autoload :Number, "super_admin/field/number"
    autoload :Boolean, "super_admin/field/boolean"
    autoload :Date, "super_admin/field/date"
    autoload :DateTime, "super_admin/field/date_time"
    autoload :Time, "super_admin/field/time"
    autoload :Email, "super_admin/field/email"
    autoload :Url, "super_admin/field/url"
    autoload :Password, "super_admin/field/password"
    autoload :Select, "super_admin/field/select"
    autoload :RichText, "super_admin/field/rich_text"
    autoload :BelongsTo, "super_admin/field/belongs_to"
    autoload :HasMany, "super_admin/field/has_many"
    autoload :HasOne, "super_admin/field/has_one"
    autoload :Polymorphic, "super_admin/field/polymorphic"
  end

  module Page
    autoload :Base, "super_admin/page/base"
    autoload :Collection, "super_admin/page/collection"
    autoload :Show, "super_admin/page/show"
    autoload :Form, "super_admin/page/form"
  end
end
