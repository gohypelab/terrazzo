require "rails/generators"

module Terrazzo
  module Generators
    module Views
      class IndexGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        class_option :namespace, type: :string, default: "admin",
          desc: "Admin namespace"

        def copy_index_template
          copy_file "pages/index.jsx", "app/views/#{namespace_name}/application/index.jsx"
        end

        private

        def namespace_name
          options[:namespace]
        end
      end
    end
  end
end
