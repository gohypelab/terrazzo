require "rails/generators"
require "terrazzo/generator_helpers"

module Terrazzo
  module Generators
    class DashboardGenerator < Rails::Generators::NamedBase
      include Terrazzo::GeneratorHelpers

      source_root File.expand_path("templates", __dir__)

      class_option :namespace, type: :string, default: "admin",
        desc: "Admin namespace"
      class_option :bundler, type: :string, default: "vite",
        desc: "JavaScript bundler (vite or sprockets)"

      def create_dashboard
        template "dashboard.rb.erb",
          "app/dashboards/#{class_path.join('/')}/#{file_name}_dashboard.rb".squeeze("/")
      end

      def create_controller
        template "controller.rb.erb",
          "app/controllers/#{options[:namespace]}/#{class_path.join('/')}/#{file_name.pluralize}_controller.rb".squeeze("/")
      end

      def update_page_to_page_mapping
        return if options[:bundler] == "vite"

        mapping_path = "app/javascript/#{options[:namespace]}/page_to_page_mapping.js"
        return unless File.exist?(mapping_path)

        namespace_name = options[:namespace]
        action_to_component = {
          "index" => "AdminIndex",
          "show" => "AdminShow",
          "new" => "AdminNew",
          "edit" => "AdminEdit"
        }

        action_to_component.each do |action, component|
          key = "'#{namespace_name}/application/#{action}'"
          mapping_path_content = File.read(mapping_path)
          next if mapping_path_content.include?(key)

          inject_into_file mapping_path, before: "}" do
            "  #{key}: #{component},\n"
          end
        end
      end

      private

      def model_class
        class_name.constantize
      end

      def attribute_types
        columns = model_class.columns.reject { |c| c.name == "id" }
        associations = model_class.reflect_on_all_associations

        types = {}

        # ID first
        types[:id] = "Field::Number"

        # Columns
        columns.each do |col|
          next if col.name.end_with?("_type") && columns.any? { |c| c.name == col.name.sub(/_type$/, "_id") }
          next if association_foreign_key?(col.name, associations)

          types[col.name.to_sym] = column_to_field_type(col)
        end

        # Associations
        associations.each do |assoc|
          case assoc.macro
          when :belongs_to
            types[assoc.name] = "Field::BelongsTo"
          when :has_many, :has_and_belongs_to_many
            types[assoc.name] = "Field::HasMany"
          when :has_one
            types[assoc.name] = "Field::HasOne"
          end
        end

        types
      end

      def collection_attributes
        attrs = attribute_types.keys.reject { |a| %i[created_at updated_at].include?(a) }
        attrs.first(4)
      end

      def show_page_attributes
        attribute_types.keys
      end

      def form_attributes
        attribute_types.keys.reject { |a| %i[id created_at updated_at].include?(a) }
      end

      def association_foreign_key?(column_name, associations)
        associations.any? do |assoc|
          assoc.macro == :belongs_to &&
            assoc.foreign_key.to_s == column_name
        end
      end

      def has_enum?(column_name)
        model_class.defined_enums.key?(column_name.to_s)
      end

      def enum_collection(column_name)
        model_class.defined_enums[column_name.to_s]&.keys || []
      end
    end
  end
end
