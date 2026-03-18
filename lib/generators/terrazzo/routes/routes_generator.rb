require "rails/generators"

module Terrazzo
  module Generators
    class RoutesGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      class_option :namespace, type: :string, default: "admin",
        desc: "Admin namespace"

      def insert_routes
        namespace_name = options[:namespace]
        models = application_models

        # Group models by their module namespace
        namespaced = {}
        top_level = []

        models.each do |model|
          parts = model.name.split("::")
          if parts.size > 1
            ns = parts[0..-2].join("::").underscore
            resource = parts.last.underscore.pluralize
            namespaced[ns] ||= []
            namespaced[ns] << resource
          else
            top_level << model.model_name.plural
          end
        end

        lines = []
        top_level.sort.each { |r| lines << "    resources :#{r}" }

        namespaced.sort.each do |ns, resources|
          lines << ""
          lines << "    namespace :#{ns} do"
          resources.sort.each { |r| lines << "      resources :#{r}" }
          lines << "    end"
        end

        first_resource = top_level.sort.first || namespaced.values.flatten.first || "dashboard"

        route_block = <<~RUBY.indent(2)
          namespace :#{namespace_name} do
          #{lines.join("\n")}

            root to: "#{first_resource}#index"
          end
        RUBY

        route route_block.strip
      end

      private

      def application_models
        models_path = Rails.root.join("app", "models")
        return [] unless models_path.exist?

        Dir[models_path.join("**", "*.rb")].filter_map do |file|
          relative = Pathname.new(file).relative_path_from(models_path).to_s
          next if relative.start_with?("concerns/")
          next if relative == "application_record.rb"

          relative.delete_suffix(".rb").camelize.safe_constantize
        end.select { |klass| klass < ApplicationRecord && !klass.abstract_class? }
         .sort_by { |klass| klass.name }
      end
    end
  end
end
