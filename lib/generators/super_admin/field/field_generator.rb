require "rails/generators"

module SuperAdmin
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

      def show_registration_instructions
        say "\nTo use your custom field, register it in your FieldRenderer.jsx:", :green
        say "  import { IndexField as #{class_name}Index } from \"./#{file_name}/IndexField\";"
        say "  import { ShowField as #{class_name}Show } from \"./#{file_name}/ShowField\";"
        say "  import { FormField as #{class_name}Form } from \"./#{file_name}/FormField\";"
        say ""
        say "  registerFieldType(\"#{file_name}\", { index: #{class_name}Index, show: #{class_name}Show, form: #{class_name}Form });"
        say ""
        say "Then use it in your dashboard:"
        say "  #{file_name}: SuperAdmin::Field::#{class_name},"
      end

      private

      def namespace_name
        options[:namespace]
      end
    end
  end
end
