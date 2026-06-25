require "rails/generators"
require_relative "generated_defaults_helper"
require_relative "page_mapping_helper"

module Terrazzo
  module Generators
    module Views
      class IndexGenerator < Rails::Generators::Base
        include GeneratedDefaultsHelper
        include PageMappingHelper

        source_root File.expand_path("templates", __dir__)

        argument :resource, type: :string, required: false,
          desc: "Resource model (e.g., User) to eject a resource-specific index view"

        class_option :namespace, type: :string, default: "admin",
          desc: "Admin namespace"

        def copy_index_template
          ensure_page_barrels

          if resource.present?
            eject_json_props
            copy_file "pages/index.jsx", "app/views/#{namespace_name}/#{resource_path}/index.jsx"
            copy_file "pages/_collection.jsx", "app/views/#{namespace_name}/#{resource_path}/_collection.jsx"
            register_page_mapping("index")
          else
            copy_file_over_generated "pages/index.jsx", "app/views/#{namespace_name}/application/index.jsx",
              generated_content: generated_page_stub("index")
            copy_file "pages/_collection.jsx", "app/views/#{namespace_name}/application/_collection.jsx"
          end
        end

        private

        def eject_json_props
          create_file "app/views/#{namespace_name}/#{resource_path}/index.json.props", <<~RUBY
            json.partial! partial: "terrazzo/application/index_base"
            # Add custom props below:
            # json.customProp SomeModel.count
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
