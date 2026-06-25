require "rails/generators"
require_relative "generated_defaults_helper"
require_relative "page_mapping_helper"

module Terrazzo
  module Generators
    module Views
      class NewGenerator < Rails::Generators::Base
        include GeneratedDefaultsHelper
        include PageMappingHelper

        source_root File.expand_path("templates", __dir__)

        argument :resource, type: :string, required: false,
          desc: "Resource model (e.g., User) to eject a resource-specific new view"

        class_option :namespace, type: :string, default: "admin",
          desc: "Admin namespace"
        class_option :with_counterpart, type: :boolean, default: nil,
          desc: "Also eject the edit view that shares this form partial"

        def copy_new_template
          ensure_page_barrels

          if resource.present?
            eject_json_props
            copy_file "pages/new.jsx", "app/views/#{namespace_name}/#{resource_path}/new.jsx"
            copy_file "pages/_form.jsx", "app/views/#{namespace_name}/#{resource_path}/_form.jsx"
            register_page_mapping("new")
            eject_edit_view if should_eject_edit?
          else
            copy_file_over_generated "pages/new.jsx", "app/views/#{namespace_name}/application/new.jsx",
              generated_content: generated_page_stub("new")
            copy_file "pages/_form.jsx", "app/views/#{namespace_name}/application/_form.jsx"
            eject_edit_view if should_eject_edit?
          end
        end

        private

        def eject_json_props
          create_file "app/views/#{namespace_name}/#{resource_path}/new.json.props", <<~RUBY
            json.partial! partial: "terrazzo/application/new_base"
            # Add custom props below:
            # json.customProp SomeModel.some_value
          RUBY
        end

        def should_eject_edit?
          edit_path = if resource.present?
            "app/views/#{namespace_name}/#{resource_path}/edit.jsx"
          else
            "app/views/#{namespace_name}/application/edit.jsx"
          end
          return true if generated_file?(edit_path, generated_page_stub("edit"))
          return false if File.exist?(edit_path)
          return options[:with_counterpart] unless options[:with_counterpart].nil?

          yes?("Also eject the edit view to share the custom form partial? (y/n)")
        end

        def eject_edit_view
          if resource.present?
            eject_edit_json_props
            copy_file "pages/edit.jsx", "app/views/#{namespace_name}/#{resource_path}/edit.jsx"
            register_page_mapping("edit")
          else
            copy_file_over_generated "pages/edit.jsx", "app/views/#{namespace_name}/application/edit.jsx",
              generated_content: generated_page_stub("edit")
          end
        end

        def eject_edit_json_props
          create_file "app/views/#{namespace_name}/#{resource_path}/edit.json.props", <<~RUBY
            json.partial! partial: "terrazzo/application/edit_base"
            # Add custom props below:
            # json.customProp @resource.some_method
          RUBY
        end

        def resource_path
          resource.underscore.pluralize
        end

        def namespace_name
          options[:namespace]
        end
      end
    end
  end
end
