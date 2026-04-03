require "rails/generators"

module Terrazzo
  module Generators
    module Views
      class NewGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        argument :resource, type: :string, required: false,
          desc: "Resource model (e.g., User) to eject a resource-specific new view"

        class_option :namespace, type: :string, default: "admin",
          desc: "Admin namespace"

        def copy_new_template
          if resource.present?
            eject_json_props
            copy_file "pages/new.jsx", "app/views/#{namespace_name}/#{resource_path}/new.jsx"
            copy_file "pages/_form.jsx", "app/views/#{namespace_name}/#{resource_path}/_form.jsx"
            eject_edit_view if should_eject_edit?
          else
            copy_file "pages/new.jsx", "app/views/#{namespace_name}/application/new.jsx"
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
          return false if File.exist?(edit_path)

          yes?("Also eject the edit view to share the custom form partial? (y/n)")
        end

        def eject_edit_view
          if resource.present?
            eject_edit_json_props
            copy_file "pages/edit.jsx", "app/views/#{namespace_name}/#{resource_path}/edit.jsx"
          else
            copy_file "pages/edit.jsx", "app/views/#{namespace_name}/application/edit.jsx"
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
