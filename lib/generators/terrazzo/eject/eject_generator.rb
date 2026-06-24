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

        field_shared_dependencies(field_type).each do |dependency|
          copy_file "fields/shared/#{dependency}.jsx",
            "app/views/#{namespace_name}/fields/shared/#{dependency}.jsx"
        end

        ensure_ui_barrel
        update_fields_barrel(field_type)
      end

      def eject_component
        name = component_name

        unless component_template_exists?(name)
          say_status :error, "Unknown component '#{name}'", :red
          return
        end

        ([name] + component_dependencies(name)).uniq.each do |component|
          copy_component_template(component)
        end

        ensure_ui_barrel
        update_components_barrel(name)
      end

      def eject_ui
        name = component_name
        source = "components/ui/#{name}.jsx"

        unless File.exist?(File.join(self.class.source_root, source))
          say_status :error, "Unknown UI component '#{name}'", :red
          return
        end

        ([name] + ui_dependencies(name)).uniq.each do |component|
          copy_ui_template(component)
          update_ui_barrel(component)
        end
      end

      def eject_page
        name = component_name
        source = "pages/#{name}.jsx"

        unless File.exist?(File.join(self.class.source_root, source))
          say_status :error, "Unknown page template '#{name}'", :red
          return
        end

        ensure_page_barrels
        copy_file source, "app/views/#{namespace_name}/application/#{name}.jsx"
        page_dependencies(name).each do |dependency|
          copy_file "pages/#{dependency}.jsx", "app/views/#{namespace_name}/application/#{dependency}.jsx"
        end
      end

      def eject_navigation
        dest = "app/views/#{namespace_name}/application/_navigation.json.props"
        copy_file "pages/_navigation.json.props", dest
        say "\nNavigation partial ejected to #{dest}.", :green
        say "Edit it to customize your admin navigation."
      end

      def update_fields_barrel(field_type)
        type_label = field_type.split("_").map(&:capitalize).join("")
        register_name = "register#{type_label}FieldType"
        local_exports = <<~JS.strip
          // #{type_label} - ejected
          import { registerFieldType as #{register_name} } from "terrazzo/fields";
          import { IndexField as #{type_label}IndexField } from "./#{field_type}/IndexField";
          import { ShowField as #{type_label}ShowField } from "./#{field_type}/ShowField";
          import { FormField as #{type_label}FormField } from "./#{field_type}/FormField";

          #{register_name}("#{field_type}", {
            index: #{type_label}IndexField,
            show: #{type_label}ShowField,
            form: #{type_label}FormField,
          });

          export { #{type_label}IndexField, #{type_label}ShowField, #{type_label}FormField };
        JS

        ensure_fields_barrel
        append_to_barrel(fields_barrel_path, local_exports, "./#{field_type}/IndexField")
      end

      def update_components_barrel(name)
        export_name = component_export_name(name)

        local_exports = if name == "Layout"
          <<~JS.strip
            // Layout - ejected
            import { setLayout } from "terrazzo";
            import { Layout } from "./Layout";

            setLayout(Layout);

            export { Layout };
          JS
        else
          <<~JS.strip
            // #{export_name} - ejected
            import { registerComponent as register#{export_name}Component } from "terrazzo/components";
            import { #{export_name} } from "./#{name}";

            register#{export_name}Component("#{export_name}", #{export_name});

            export { #{export_name} } from "./#{name}";
          JS
        end

        ensure_components_barrel
        append_to_barrel(components_barrel_path, local_exports, "./#{name}")
      end

      def update_ui_barrel(name)
        local_exports = ui_component_exports(name)
        ensure_ui_barrel
        append_to_barrel(ui_barrel_path, "// #{name} - ejected\nexport { #{local_exports} } from \"./#{name}\";", "./#{name}")
      end

      def component_export_name(file_name)
        case file_name
        when "app-sidebar" then "AppSidebar"
        when "site-header" then "SiteHeader"
        else file_name
        end
      end

      def component_template_exists?(name)
        File.exist?(File.join(self.class.source_root, "components/#{name}.jsx"))
      end

      def copy_component_template(name)
        copy_file "components/#{name}.jsx", "app/views/#{namespace_name}/components/#{name}.jsx"
      end

      def copy_ui_template(name)
        copy_file "components/ui/#{name}.jsx", "app/views/#{namespace_name}/components/ui/#{name}.jsx"
      end

      def field_shared_dependencies(field_type)
        field_template_paths(field_type).flat_map do |path|
          relative_imports(File.read(path)).filter_map do |specifier|
            next unless specifier.start_with?("../shared/")

            dependency = File.basename(specifier, ".*")
            next unless template_exists?("fields/shared/#{dependency}.jsx")

            dependency
          end
        end.uniq
      end

      def component_dependencies(name)
        template_dependencies("components/#{name}.jsx", "components")
      end

      def page_dependencies(name)
        template_dependencies("pages/#{name}.jsx", "pages")
      end

      def ui_dependencies(name)
        template_dependencies("components/ui/#{name}.jsx", "components/ui")
      end

      def template_dependencies(template, template_root, seen = [])
        template_path = File.join(self.class.source_root, template)
        return [] unless File.exist?(template_path)

        relative_imports(File.read(template_path)).flat_map do |specifier|
          next unless specifier.start_with?("./")

          dependency = File.basename(specifier.delete_prefix("./"), ".*")
          dependency_template = "#{template_root}/#{dependency}.jsx"
          next unless template_exists?(dependency_template)
          next if seen.include?(dependency)

          [dependency, *template_dependencies(dependency_template, template_root, seen + [dependency])]
        end.compact.uniq
      end

      def field_template_paths(field_type)
        Dir[File.join(self.class.source_root, "fields", field_type, "*.jsx")]
      end

      def relative_imports(source)
        source.scan(/from\s+["']([^"']+)["']/).flatten
      end

      def template_exists?(template)
        File.exist?(File.join(self.class.source_root, template))
      end

      def ui_component_exports(name)
        ui_barrel_template = File.read(File.join(self.class.source_root, "components/ui/index.js"))
        match = ui_barrel_template.match(/^export\s*\{(?<exports>[^}]*)\}\s*from\s*["']\.\/#{Regexp.escape(name)}["'];/m)
        raise Thor::Error, "Could not find UI exports for '#{name}'" unless match

        match[:exports].split(",").map(&:strip).reject(&:empty?).join(", ")
      end

      def ensure_barrel(barrel_path, package_export)
        barrel_file = File.join(destination_root, barrel_path)

        unless File.exist?(barrel_file)
          create_file barrel_path, "#{package_export}\n"
          return
        end

        content = File.read(barrel_file)
        return if content.include?(package_export)

        prepend_to_file barrel_path, "#{package_export}\n"
      end

      def ensure_page_barrels
        ensure_fields_barrel
        ensure_components_barrel
        ensure_ui_barrel
      end

      def ensure_fields_barrel
        ensure_barrel(fields_barrel_path, 'export * from "terrazzo/fields";')
      end

      def ensure_components_barrel
        ensure_barrel(components_barrel_path, 'export * from "terrazzo/components";')
      end

      def ensure_ui_barrel
        ensure_barrel(ui_barrel_path, 'export * from "terrazzo/ui";')
      end

      def fields_barrel_path
        "app/views/#{namespace_name}/fields/index.js"
      end

      def components_barrel_path
        "app/views/#{namespace_name}/components/index.js"
      end

      def ui_barrel_path
        "app/views/#{namespace_name}/components/ui/index.js"
      end

      def append_to_barrel(barrel_path, content, marker)
        barrel_file = File.join(destination_root, barrel_path)
        return if File.exist?(barrel_file) && File.read(barrel_file).include?(marker)

        append_to_file barrel_path, "\n#{content}\n"
      end
    end
  end
end
