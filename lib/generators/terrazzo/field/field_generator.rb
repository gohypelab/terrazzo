require "rails/generators"

module Terrazzo
  module Generators
    class FieldGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :namespace, type: :string, default: "admin",
        desc: "Admin namespace"

      def create_field_class
        template "field.rb.erb",
          "app/fields/#{file_name}_field.rb"
      end

      def create_jsx_components
        %w[IndexField ShowField FormField].each do |component|
          template "#{component}.jsx.erb",
            "app/views/#{namespace_name}/fields/#{file_name}/#{component}.jsx"
        end
      end

      def register_in_barrel
        barrel_path = File.join(destination_root, "app/views/#{namespace_name}/fields/index.js")
        return unless File.exist?(barrel_path)

        registration = <<~JS

          // #{class_name} - custom field
          export { IndexField as #{class_name}IndexField } from "./#{file_name}/IndexField";
          export { ShowField as #{class_name}ShowField } from "./#{file_name}/ShowField";
          export { FormField as #{class_name}FormField } from "./#{file_name}/FormField";
        JS

        append_to_file "app/views/#{namespace_name}/fields/index.js", registration

        say "\nCustom field '#{file_name}' registered in fields/index.js.", :green
        say "Use it in your dashboard:"
        say "  #{file_name}: Terrazzo::Field::#{class_name},"
      end

      private

      def namespace_name
        options[:namespace]
      end
    end
  end
end
