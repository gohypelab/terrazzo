require "rails/generators"

module SuperAdmin
  module Generators
    module Views
      class LayoutGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        class_option :namespace, type: :string, default: "admin",
          desc: "Admin namespace"

        def copy_layout_components
          %w[Layout.jsx app-sidebar.jsx site-header.jsx FlashMessages.jsx].each do |file|
            copy_file "components/#{file}", "app/views/#{namespace_name}/components/#{file}"
          end
        end

        private

        def namespace_name
          options[:namespace]
        end
      end
    end
  end
end
