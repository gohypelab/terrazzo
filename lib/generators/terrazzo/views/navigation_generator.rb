require "rails/generators"
require "generators/terrazzo/views/eject_compatibility"

module Terrazzo
  module Generators
    module Views
      class NavigationGenerator < Rails::Generators::Base
        include EjectCompatibility

        source_root File.expand_path("templates", __dir__)

        class_option :namespace, type: :string, default: "admin",
          desc: "Admin namespace"

        def copy_navigation
          run_eject("navigation")
          run_eject("components/app-sidebar")
        end

        private

        def namespace_name
          options[:namespace]
        end
      end
    end
  end
end
