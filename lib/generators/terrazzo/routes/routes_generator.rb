require "rails/generators"

module Terrazzo
  module Generators
    class RoutesGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      class_option :namespace, type: :string, default: "admin",
        desc: "Admin namespace"

      def insert_routes
        namespace_name = options[:namespace]
        route_content = <<~RUBY.indent(2)
          namespace :#{namespace_name} do
            root to: "#{first_resource}#index"
          end
        RUBY

        route route_content.strip
      end

      private

      def first_resource
        # Default to "customers" if no models found
        models = application_models
        models.any? ? models.first.model_name.plural : "dashboard"
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
