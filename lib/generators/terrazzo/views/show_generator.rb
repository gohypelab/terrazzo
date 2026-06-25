require "rails/generators"
require_relative "generated_defaults_helper"
require_relative "page_mapping_helper"

module Terrazzo
  module Generators
    module Views
      class ShowGenerator < Rails::Generators::Base
        include GeneratedDefaultsHelper
        include PageMappingHelper

        source_root File.expand_path("templates", __dir__)

        argument :resource, type: :string, required: false,
          desc: "Resource model (e.g., User) to eject a resource-specific show view"

        class_option :namespace, type: :string, default: "admin",
          desc: "Admin namespace"

        def copy_show_template
          ensure_page_barrels

          if resource.present?
            eject_json_props
            copy_resource_page_file "pages/show.jsx", "app/views/#{namespace_name}/#{resource_path}/show.jsx"
            register_page_mapping("show")
          else
            copy_file_over_generated "pages/show.jsx", "app/views/#{namespace_name}/application/show.jsx",
              generated_content: generated_page_stub("show")
          end
        end

        private

        def eject_json_props
          create_file "app/views/#{namespace_name}/#{resource_path}/show.json.props", <<~RUBY
            json.partial! partial: "terrazzo/application/show_base"
            # Add custom props below:
            # json.customProp @resource.some_method
          RUBY
        end

        def namespace_name
          options[:namespace]
        end
      end
    end
  end
end
