require "rails/generators"

module Terrazzo
  module Generators
    module Views
      class NewGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        class_option :namespace, type: :string, default: "admin",
          desc: "Admin namespace"

        def copy_new_template
          copy_file "pages/new.jsx", "app/views/#{namespace_name}/application/new.jsx"
        end

        def copy_form_partial
          copy_file "pages/_form.jsx", "app/views/#{namespace_name}/application/_form.jsx"
        end

        private

        def namespace_name
          options[:namespace]
        end
      end
    end
  end
end
