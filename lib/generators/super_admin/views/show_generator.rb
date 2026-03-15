require "rails/generators"

module SuperAdmin
  module Generators
    module Views
      class ShowGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        class_option :namespace, type: :string, default: "admin",
          desc: "Admin namespace"

        def copy_show_template
          copy_file "pages/show.jsx", "app/views/#{namespace_name}/application/show.jsx"
        end

        private

        def namespace_name
          options[:namespace]
        end
      end
    end
  end
end
