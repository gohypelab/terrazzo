require "rails/generators"

module SuperAdmin
  module Generators
    module Views
      class NavigationGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        class_option :namespace, type: :string, default: "admin",
          desc: "Admin namespace"

        def copy_navigation
          copy_file "components/app-sidebar.jsx", "app/views/#{namespace_name}/components/app-sidebar.jsx"
        end

        private

        def namespace_name
          options[:namespace]
        end
      end
    end
  end
end
