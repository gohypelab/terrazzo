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
        raise_no_models_error if models.empty?

        route_tree = empty_route_tree

        models.each do |model|
          parts = model.name.split("::")
          if parts.size > 1
            namespaces = parts[0..-2].map(&:underscore)
            resource = parts.last.underscore.pluralize
            add_route_resource(route_tree, namespaces, resource)
          else
            add_route_resource(route_tree, [], model.model_name.plural)
          end
        end

        lines = route_lines(route_tree, indent_level: 1)
        first_resource = first_route_target(route_tree)

        route_block = <<~RUBY
          namespace :#{namespace_name} do
          #{lines.join("\n")}

            root to: "#{first_resource}#index"
          end
        RUBY

        if File.read(Rails.root.join("config/routes.rb")).include?("namespace :#{namespace_name}")
          say_status :skip, "namespace :#{namespace_name} already exists in config/routes.rb", :yellow
          say ""
          say "Add these resource routes to your existing namespace :#{namespace_name} block:", :green
          say ""
          lines.each { |line| say line }
          say ""
          say "  root to: \"#{first_resource}#index\"", :green if first_resource
          say ""
          return
        end

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

      def empty_route_tree
        { resources: [], namespaces: {} }
      end

      def add_route_resource(tree, namespaces, resource)
        if namespaces.empty?
          tree[:resources] << resource
          return
        end

        namespace = namespaces.first
        child_tree = tree[:namespaces][namespace] ||= empty_route_tree
        add_route_resource(child_tree, namespaces.drop(1), resource)
      end

      def route_lines(tree, indent_level:)
        indent = "  " * indent_level
        lines = tree[:resources].uniq.sort.map { |resource| "#{indent}resources :#{resource}" }

        tree[:namespaces].sort.each do |namespace, child_tree|
          lines << "" if lines.any?
          lines << "#{indent}namespace :#{namespace} do"
          lines.concat(route_lines(child_tree, indent_level: indent_level + 1))
          lines << "#{indent}end"
        end

        lines
      end

      def first_route_target(tree)
        resource = tree[:resources].uniq.sort.first
        return resource if resource

        namespace, child_tree = tree[:namespaces].sort.first
        child_target = first_route_target(child_tree) if child_tree
        return "#{namespace}/#{child_target}" if namespace && child_target
      end

      def raise_no_models_error
        raise Thor::Error, <<~MESSAGE
          Terrazzo could not find any ApplicationRecord models to route.

          Add at least one model first, then run `bin/rails generate terrazzo:routes` again.
        MESSAGE
      end
    end
  end
end
