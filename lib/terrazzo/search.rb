module Terrazzo
  class Search
    attr_reader :scoped_resource, :dashboard, :term

    def initialize(scoped_resource, dashboard, term)
      @scoped_resource = scoped_resource
      @dashboard = dashboard
      @term = term
    end

    def run
      term.blank? ? scoped_resource : search_results
    end

    private

    LIKE_ESCAPE = "\\"

    def search_results
      searchable_attributes = dashboard.search_attributes
      return scoped_resource if searchable_attributes.empty?

      conditions =
        searchable_attributes
          .map do |attr|
            type = dashboard.attribute_type_for(attr)

            if type.respond_to?(:associative?) && type.associative?
              build_association_search(attr, type)
            else
              text_attribute(scoped_resource.model, attr).matches(search_pattern, LIKE_ESCAPE)
            end
          end
          .compact

      return scoped_resource if conditions.empty?

      combined = conditions.reduce(:or)
      scoped_resource.where(combined)
    end

    def build_association_search(attr, type)
      reflection = scoped_resource.model.reflect_on_association(attr)
      return nil unless reflection

      columns = association_search_columns(type, reflection.klass)
      return nil if columns.empty?

      condition =
        columns
          .map { |column| text_attribute(reflection.klass, column).matches(search_pattern, LIKE_ESCAPE) }
          .reduce(:or)

      # Match IDs so association joins do not duplicate rows or compare JSON columns.
      model = scoped_resource.model
      primary_key = model.arel_table[model.primary_key]
      ids = model.joins(attr).where(condition).select(primary_key)
      primary_key.in(ids.arel)
    end

    def association_search_columns(type, associated_class)
      configured = type.respond_to?(:options) ? Array(type.options[:searchable_fields]) : []
      candidates = configured.presence || %i[name title email]
      column_names = associated_class.column_names + associated_class.stored_attributes.values.flatten.map(&:to_s)

      candidates.map(&:to_s).select { |column| column_names.include?(column) }.map(&:to_sym)
    end

    def text_attribute(model, attribute)
      store = model.stored_attributes.find { |_column, fields| fields.include?(attribute.to_sym) }
      expression =
        if store
          Arel::Nodes::InfixOperation.new(
            "->>",
            model.arel_table[store.first],
            Arel::Nodes.build_quoted(attribute.to_s)
          )
        else
          model.arel_table[attribute]
        end
      Arel::Nodes::NamedFunction.new("CAST", [expression.as("text")])
    end

    def search_pattern
      "%#{ActiveRecord::Base.sanitize_sql_like(term.to_s, LIKE_ESCAPE)}%"
    end
  end
end
