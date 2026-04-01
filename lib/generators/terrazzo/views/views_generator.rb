require "rails/generators"

module Terrazzo
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      class_option :namespace, type: :string, default: "admin",
        desc: "Admin namespace"

      def create_fields_barrel
        create_file "app/views/#{namespace_name}/fields/index.js", <<~JS
          // Re-export all fields from the terrazzo package.
          // To customize a field, run: rails g terrazzo:eject fields/<field_type>
          export * from "terrazzo/fields";
        JS
      end

      def create_components_barrel
        create_file "app/views/#{namespace_name}/components/index.js", <<~JS
          // Re-export all components from the terrazzo package.
          // To customize, run: rails g terrazzo:eject components/<component_name>
          export * from "terrazzo/components";
        JS
      end

      def create_ui_barrel
        create_file "app/views/#{namespace_name}/components/ui/index.js", <<~JS
          // Re-export all UI primitives from the terrazzo package.
          // To customize, run: rails g terrazzo:eject ui/<component_name>
          export * from "terrazzo/ui";
        JS
      end

      def create_navigation_partial
        create_file "app/views/#{namespace_name}/application/_navigation.json.props", <<~RUBY
          resources = Terrazzo::Namespace.new(namespace).resources_with_index_route

          json.array! [{ label: "Resources", resources: resources }] do |group|
            json.label group[:label]
            json.items do
              json.array! group[:resources] do |r|
                json.label r.resource_name.humanize.pluralize
                json.path url_for(controller: "/\#{r.controller_path}", action: :index, only_path: true)
                json.active r.controller_path == controller_path
              end
            end
          end
        RUBY
      end

      def create_page_stubs
        {
          "index" => "AdminIndex",
          "show" => "AdminShow",
          "new" => "AdminNew",
          "edit" => "AdminEdit",
        }.each do |page, component|
          create_file "app/views/#{namespace_name}/application/#{page}.jsx",
            "export { #{component} as default } from \"terrazzo/pages\";\n"
        end
      end

      private

      def namespace_name
        options[:namespace]
      end
    end
  end
end
