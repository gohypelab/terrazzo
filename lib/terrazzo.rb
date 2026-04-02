require "kaminari"
require "props_template"
require "form_props"
require "terrazzo/version"
require "terrazzo/engine"
require "terrazzo/not_authorized_error"

module Terrazzo
  autoload :BaseDashboard, "terrazzo/base_dashboard"
  autoload :ResourceResolver, "terrazzo/resource_resolver"
  autoload :Search, "terrazzo/search"
  autoload :Order, "terrazzo/order"
  autoload :Filter, "terrazzo/filter"
  autoload :Namespace, "terrazzo/namespace"
  autoload :GeneratorHelpers, "terrazzo/generator_helpers"
  autoload :UsesSuperglue, "terrazzo/uses_superglue"

  module Field
    autoload :Base, "terrazzo/field/base"
    autoload :Deferred, "terrazzo/field/deferred"
    autoload :Associative, "terrazzo/field/associative"
    autoload :String, "terrazzo/field/string"
    autoload :Text, "terrazzo/field/text"
    autoload :Number, "terrazzo/field/number"
    autoload :Money, "terrazzo/field/money"
    autoload :Boolean, "terrazzo/field/boolean"
    autoload :Date, "terrazzo/field/date"
    autoload :DateTime, "terrazzo/field/date_time"
    autoload :Time, "terrazzo/field/time"
    autoload :Email, "terrazzo/field/email"
    autoload :Url, "terrazzo/field/url"
    autoload :Password, "terrazzo/field/password"
    autoload :Select, "terrazzo/field/select"
    autoload :Hstore, "terrazzo/field/hstore"
    autoload :RichText, "terrazzo/field/rich_text"
    autoload :BelongsTo, "terrazzo/field/belongs_to"
    autoload :HasMany, "terrazzo/field/has_many"
    autoload :HasOne, "terrazzo/field/has_one"
    autoload :Polymorphic, "terrazzo/field/polymorphic"
    autoload :Asset, "terrazzo/field/asset"
  end

  module Page
    autoload :Base, "terrazzo/page/base"
    autoload :Collection, "terrazzo/page/collection"
    autoload :Show, "terrazzo/page/show"
    autoload :Form, "terrazzo/page/form"
  end
end
