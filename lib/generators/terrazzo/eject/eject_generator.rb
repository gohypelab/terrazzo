require "rails/generators"

module Terrazzo
  module Generators
    class EjectGenerator < Rails::Generators::Base
      source_root File.expand_path("../views/templates", __dir__)

      argument :target, type: :string,
        desc: "What to eject (e.g., fields/string, components/Layout, ui/button, pages/index)"

      class_option :namespace, type: :string, default: "admin",
        desc: "Admin namespace"

      def eject
        case category
        when "fields"
          eject_field
        when "components"
          eject_component
        when "ui"
          eject_ui
        when "pages"
          eject_page
        when "navigation"
          eject_navigation
        else
          say_status :error, "Unknown category '#{category}'. Use fields/, components/, ui/, pages/, or navigation", :red
        end
      end

      private

      def category
        target.split("/").first
      end

      def component_name
        target.split("/", 2).last
      end

      def namespace_name
        options[:namespace]
      end

      def eject_field
        field_type = component_name
        source_dir = "fields/#{field_type}"

        unless File.directory?(File.join(self.class.source_root, source_dir))
          say_status :error, "Unknown field type '#{field_type}'", :red
          return
        end

        %w[IndexField.jsx ShowField.jsx FormField.jsx].each do |file|
          source = File.join(source_dir, file)
          next unless File.exist?(File.join(self.class.source_root, source))
          copy_file source, "app/views/#{namespace_name}/fields/#{field_type}/#{file}"
        end

        # Copy shared dependencies if needed
        if field_uses_shared?(field_type)
          copy_file "fields/shared/TextInputFormField.jsx",
            "app/views/#{namespace_name}/fields/shared/TextInputFormField.jsx"
        end

        update_fields_barrel(field_type)
      end

      def eject_component
        name = component_name
        source = "components/#{name}.jsx"

        unless File.exist?(File.join(self.class.source_root, source))
          say_status :error, "Unknown component '#{name}'", :red
          return
        end

        copy_file source, "app/views/#{namespace_name}/components/#{name}.jsx"
        update_components_barrel(name)
      end

      def eject_ui
        name = component_name
        source = "components/ui/#{name}.jsx"

        unless File.exist?(File.join(self.class.source_root, source))
          say_status :error, "Unknown UI component '#{name}'", :red
          return
        end

        copy_file source, "app/views/#{namespace_name}/components/ui/#{name}.jsx"
        update_ui_barrel(name)
      end

      def eject_page
        name = component_name
        source = "pages/#{name}.jsx"

        unless File.exist?(File.join(self.class.source_root, source))
          say_status :error, "Unknown page template '#{name}'", :red
          return
        end

        copy_file source, "app/views/#{namespace_name}/application/#{name}.jsx"
      end

      def eject_navigation
        source = File.join(Terrazzo::Engine.root, "app/views/terrazzo/application/_navigation.json.props")
        dest = "app/views/#{namespace_name}/application/_navigation.json.props"
        copy_file source, dest
        say "\nNavigation partial ejected to #{dest}.", :green
        say "Edit it to customize your admin navigation."
      end

      def field_uses_shared?(field_type)
        %w[string number email url password date date_time time].include?(field_type)
      end

      def update_fields_barrel(field_type)
        barrel_path = "app/views/#{namespace_name}/fields/index.js"
        barrel_file = File.join(destination_root, barrel_path)

        type_label = field_type.split("_").map(&:capitalize).join("")
        local_exports = <<~JS.strip
          // #{type_label} - ejected
          export { IndexField as #{type_label}IndexField } from "./#{field_type}/IndexField";
          export { ShowField as #{type_label}ShowField } from "./#{field_type}/ShowField";
          export { FormField as #{type_label}FormField } from "./#{field_type}/FormField";
        JS

        if File.exist?(barrel_file)
          content = File.read(barrel_file)

          # If barrel is still the default re-export-all, replace with explicit exports
          if content.include?('export * from "terrazzo/fields"')
            new_content = build_fields_barrel_with_ejection(field_type)
            create_file barrel_path, new_content, force: true
          else
            # Barrel already has explicit exports; replace the line for this field type
            # by inserting local exports before the terrazzo re-exports
            unless content.include?("./#{field_type}/")
              append_to_file barrel_path, "\n#{local_exports}\n"
            end
          end
        end
      end

      def build_fields_barrel_with_ejection(ejected_field_type)
        all_field_types = %w[
          string text number boolean date date_time time email url password
          select rich_text belongs_to has_many has_one polymorphic hstore
        ]

        lines = ['export { FieldRenderer, registerFieldType } from "terrazzo/fields";', ""]

        all_field_types.each do |ft|
          label = ft.split("_").map(&:capitalize).join("")
          if ft == ejected_field_type
            lines << "// #{label} - ejected"
            lines << "export { IndexField as #{label}IndexField } from \"./#{ft}/IndexField\";"
            lines << "export { ShowField as #{label}ShowField } from \"./#{ft}/ShowField\";"
            lines << "export { FormField as #{label}FormField } from \"./#{ft}/FormField\";"
          else
            lines << "export { #{label}IndexField, #{label}ShowField, #{label}FormField } from \"terrazzo/fields\";"
          end
        end

        lines.join("\n") + "\n"
      end

      def update_components_barrel(name)
        barrel_path = "app/views/#{namespace_name}/components/index.js"
        barrel_file = File.join(destination_root, barrel_path)

        return unless File.exist?(barrel_file)

        content = File.read(barrel_file)
        if content.include?('export * from "terrazzo/components"')
          export_name = component_export_name(name)
          new_content = build_components_barrel_with_ejection(name, export_name)
          create_file barrel_path, new_content, force: true
        end
      end

      def build_components_barrel_with_ejection(ejected_name, export_name)
        all_components = {
          "Layout" => "Layout",
          "app-sidebar" => "AppSidebar",
          "site-header" => "SiteHeader",
          "FlashMessages" => "FlashMessages",
          "SearchBar" => "SearchBar",
          "Pagination" => "Pagination",
          "SortableHeader" => "SortableHeader",
        }

        lines = []
        all_components.each do |file_name, export|
          if file_name == ejected_name
            lines << "export { #{export} } from \"./#{file_name}\"; // ejected"
          else
            lines << "export { #{export} } from \"terrazzo/components\";"
          end
        end

        lines.join("\n") + "\n"
      end

      def update_ui_barrel(name)
        barrel_path = "app/views/#{namespace_name}/components/ui/index.js"
        barrel_file = File.join(destination_root, barrel_path)

        return unless File.exist?(barrel_file)

        content = File.read(barrel_file)
        if content.include?('export * from "terrazzo/ui"')
          new_content = "export * from \"terrazzo/ui\";\n"
          new_content += "// Override ejected UI component:\n"
          new_content += "export * from \"./#{name}\";\n"
          create_file barrel_path, new_content, force: true
        end
      end

      def component_export_name(file_name)
        case file_name
        when "app-sidebar" then "AppSidebar"
        when "site-header" then "SiteHeader"
        else file_name
        end
      end
    end
  end
end
