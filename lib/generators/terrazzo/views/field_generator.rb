require "rails/generators"
require "generators/terrazzo/views/eject_compatibility"

module Terrazzo
  module Generators
    module Views
      class FieldGenerator < Rails::Generators::Base
        include EjectCompatibility

        source_root File.expand_path("templates", __dir__)

        class_option :namespace, type: :string, default: "admin",
          desc: "Admin namespace"

        argument :field_type, type: :string, required: false, default: "all",
          desc: "Specific field type to copy (e.g., string, number) or 'all'"

        def copy_field_templates
          field_types_to_eject.each { |name| run_eject("fields/#{name}") }
        end

        private

        def field_types_to_eject
          return built_in_field_types if field_type == "all"

          [field_type == "money" ? "number" : field_type]
        end

        def built_in_field_types
          Dir[File.join(self.class.source_root, "fields/*")]
            .select { |path| File.directory?(path) }
            .map { |path| File.basename(path) }
            .reject { |name| name == "shared" }
            .sort
        end

        def namespace_name
          options[:namespace]
        end
      end
    end
  end
end
