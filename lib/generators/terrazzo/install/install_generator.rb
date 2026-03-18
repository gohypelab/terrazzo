require "rails/generators"

module Terrazzo
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      class_option :namespace, type: :string, default: "admin",
        desc: "Admin namespace"
      class_option :bundler, type: :string, default: "vite",
        desc: "JavaScript bundler (vite or sprockets)"

      def create_application_controller
        template "application_controller.rb.erb",
          "app/controllers/#{namespace_name}/application_controller.rb"
      end

      def create_layout
        template "superglue.html.erb.erb",
          "app/views/layouts/#{namespace_name}/application.html.erb"
      end

      def create_json_props_layout
        copy_file "application.json.props",
          "app/views/layouts/#{namespace_name}/application.json.props"
      end

      def create_js_entry_point
        template "application.js.erb",
          "app/javascript/#{namespace_name}/application.jsx"
      end

      def create_store
        template "store.js.erb",
          "app/javascript/#{namespace_name}/store.js"
      end

      def create_page_to_page_mapping
        template "page_to_page_mapping.js.erb",
          "app/javascript/#{namespace_name}/page_to_page_mapping.js"
      end

      def create_application_visit
        template "application_visit.js.erb",
          "app/javascript/#{namespace_name}/application_visit.js"
      end

      def create_flash_slice
        template "flash_slice.js.erb",
          "app/javascript/#{namespace_name}/slices/flash.js"
      end

      def create_stylesheet
        copy_file "admin.css",
          "app/assets/stylesheets/#{namespace_name}.css"
      end

      def run_views_generator
        generate "terrazzo:views", "--namespace=#{namespace_name}"
      end

      def run_routes_generator
        generate "terrazzo:routes", "--namespace=#{namespace_name}"
      end

      def run_dashboard_generators
        application_models.each do |model|
          generate "terrazzo:dashboard", model.name, "--namespace=#{namespace_name}", "--bundler=#{options[:bundler]}"
        end
      end

      private

      def namespace_name
        options[:namespace]
      end

      def vite?
        options[:bundler] == "vite"
      end

      def application_models
        models_path = Rails.root.join("app", "models")
        return [] unless models_path.exist?

        Dir[models_path.join("**", "*.rb")].filter_map do |file|
          relative = Pathname.new(file).relative_path_from(models_path).to_s
          next if relative.start_with?("concerns/")
          next if relative == "application_record.rb"

          relative.delete_suffix(".rb").camelize.safe_constantize
        end.select { |klass| klass < ApplicationRecord && !klass.abstract_class? }
      end
    end
  end
end
