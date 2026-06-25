require "rails/generators"
require "set"
require "terrazzo/generator_helpers"

module Terrazzo
  module Generators
    class DashboardGenerator < Rails::Generators::NamedBase
      include Terrazzo::GeneratorHelpers

      source_root File.expand_path("templates", __dir__)

      class_option :namespace, type: :string, default: "admin",
        desc: "Admin namespace"
      class_option :bundler, type: :string, default: "vite",
        desc: "JavaScript bundler (vite or esbuild)"

      def create_dashboard
        template "dashboard.rb.erb",
          "app/dashboards/#{class_path.join('/')}/#{file_name}_dashboard.rb".squeeze("/")
      end

      def create_controller
        template "controller.rb.erb",
          "app/controllers/#{options[:namespace]}/#{class_path.join('/')}/#{file_name.pluralize}_controller.rb".squeeze("/")
      end

      def update_page_to_page_mapping
        # The generated page mapping falls back from resource identifiers
        # (admin/posts/index) to shared application pages (admin/application/index).
        # Resource-specific page generators register their own mappings in
        # generated_page_mapping.js when needed.
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
        types[:id] = "Field::String"

        # Columns
        columns.each do |col|
          next if col.name.end_with?("_type") && columns.any? { |c| c.name == col.name.sub(/_type$/, "_id") }
          next if association_foreign_key?(col.name, associations)

          types[col.name.to_sym] = has_enum?(col.name) ? "Field::Select" : column_to_field_type(col)
        end

        # Active Storage attachment names (used to filter internal associations)
        attachment_names = if model_class.respond_to?(:reflect_on_all_attachments)
          model_class.reflect_on_all_attachments.map(&:name).to_set
        else
          Set.new
        end
        rich_text_association_names = rich_text_internal_association_names

        rich_text_attribute_names.each do |name|
          types[name] = "Field::RichText"
        end

        # Associations
        associations.each do |assoc|
          # Skip Active Storage internal associations (e.g., document_attachment, document_blob)
          next if active_storage_internal?(assoc.name, attachment_names)
          # Skip Action Text internals (e.g., rich_text_description)
          next if rich_text_association_names.include?(assoc.name)

          case assoc.macro
          when :belongs_to
            types[assoc.name] = assoc.options[:polymorphic] ? "Field::Polymorphic" : "Field::BelongsTo"
          when :has_many, :has_and_belongs_to_many
            types[assoc.name] = "Field::HasMany"
          when :has_one
            types[assoc.name] = "Field::HasOne"
          end
        end

        # Active Storage attachments
        attachment_names.each do |name|
          attachment = model_class.reflect_on_attachment(name)
          next if attachment.macro == :has_many_attached
          types[name] = "Field::Asset"
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

      def controller_modules
        [options[:namespace].camelize, *class_path.map(&:camelize)]
      end

      def controller_class_name
        "#{file_name.pluralize.camelize}Controller"
      end

      def dashboard_modules
        class_path.map(&:camelize)
      end

      def dashboard_class_name
        "#{file_name.camelize}Dashboard"
      end

      def association_foreign_key?(column_name, associations)
        associations.any? do |assoc|
          assoc.macro == :belongs_to &&
            assoc.foreign_key.to_s == column_name
        end
      end

      def active_storage_internal?(assoc_name, attachment_names)
        name = assoc_name.to_s
        attachment_names.any? do |att|
          att_s = att.to_s
          name == "#{att_s}_attachment" || name == "#{att_s}_blob" ||
            name == "#{att_s}_attachments" || name == "#{att_s}_blobs"
          end
      end

      def rich_text_internal_association_names
        return Set.new unless model_class.respond_to?(:rich_text_association_names)

        model_class.rich_text_association_names.map(&:to_sym).to_set
      end

      def rich_text_attribute_names
        rich_text_internal_association_names.map do |name|
          name.to_s.sub(/\Arich_text_/, "").to_sym
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
