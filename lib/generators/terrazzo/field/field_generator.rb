require "rails/generators"

module Terrazzo
  module Generators
    class FieldGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :namespace, type: :string, default: "admin",
        desc: "Admin namespace"

      def create_field_class
        template "field.rb.erb",
          "app/fields/terrazzo/field/#{file_name}.rb"
      end

      def create_jsx_components
        %w[IndexField ShowField FormField].each do |component|
          template "#{component}.jsx.erb",
            "app/views/#{namespace_name}/fields/#{file_name}/#{component}.jsx"
        end
      end

      def register_in_barrel
        ensure_fields_barrel
        ensure_ui_barrel

        barrel_path = "app/views/#{namespace_name}/fields/index.js"
        barrel_file = File.join(destination_root, barrel_path)
        return if File.read(barrel_file).include?("./#{file_name}/IndexField")

        register_name = "register#{class_name}FieldType"
        registration = <<~JS

          // #{class_name} - custom field
          import { registerFieldType as #{register_name} } from "terrazzo/fields";
          import { IndexField as #{class_name}IndexField } from "./#{file_name}/IndexField";
          import { ShowField as #{class_name}ShowField } from "./#{file_name}/ShowField";
          import { FormField as #{class_name}FormField } from "./#{file_name}/FormField";

          #{register_name}("#{file_name}", {
            index: #{class_name}IndexField,
            show: #{class_name}ShowField,
            form: #{class_name}FormField,
          });

          export { #{class_name}IndexField, #{class_name}ShowField, #{class_name}FormField };
        JS

        append_to_file barrel_path, registration

        say "\nCustom field '#{file_name}' registered in fields/index.js.", :green
        say "Use it in your dashboard:"
        say "  #{file_name}: Terrazzo::Field::#{class_name},"
      end

      private

      def namespace_name
        options[:namespace]
      end

      def ensure_fields_barrel
        barrel_path = "app/views/#{namespace_name}/fields/index.js"
        barrel_file = File.join(destination_root, barrel_path)

        unless File.exist?(barrel_file)
          create_file barrel_path, %(export * from "terrazzo/fields";\n)
          return
        end

        content = File.read(barrel_file)
        return if content.include?('export * from "terrazzo/fields";')

        prepend_to_file barrel_path, %(export * from "terrazzo/fields";\n)
      end

      def ensure_ui_barrel
        barrel_path = "app/views/#{namespace_name}/components/ui/index.js"
        barrel_file = File.join(destination_root, barrel_path)

        unless File.exist?(barrel_file)
          create_file barrel_path, %(export * from "terrazzo/ui";\n)
          return
        end

        content = File.read(barrel_file)
        return if content.include?('export * from "terrazzo/ui";')

        prepend_to_file barrel_path, %(export * from "terrazzo/ui";\n)
      end
    end
  end
end
