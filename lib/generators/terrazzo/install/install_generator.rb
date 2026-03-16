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

      def create_js_entry_point
        template "application.js.erb",
          "app/javascript/#{namespace_name}/application.jsx"
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
        Rails.application.eager_load! if defined?(Rails)
        ApplicationRecord.descendants.reject(&:abstract_class?)
      rescue
        []
      end
    end
  end
end
