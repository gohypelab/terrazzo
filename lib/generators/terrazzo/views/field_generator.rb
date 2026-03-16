require "rails/generators"

module Terrazzo
  module Generators
    module Views
      class FieldGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        class_option :namespace, type: :string, default: "admin",
          desc: "Admin namespace"

        argument :field_type, type: :string, required: false, default: "all",
          desc: "Specific field type to copy (e.g., string, number) or 'all'"

        def copy_field_templates
          if field_type == "all"
            directory "fields", "app/views/#{namespace_name}/fields"
          else
            directory "fields/shared", "app/views/#{namespace_name}/fields/shared"
            directory "fields/#{field_type}", "app/views/#{namespace_name}/fields/#{field_type}"
          end
        end

        private

        def namespace_name
          options[:namespace]
        end
      end
    end
  end
end
