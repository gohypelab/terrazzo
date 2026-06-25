module Terrazzo
  class Search
    attr_reader :scoped_resource, :dashboard, :term

    def initialize(scoped_resource, dashboard, term)
      @scoped_resource = scoped_resource
      @dashboard = dashboard
      @term = term
    end

    def run
      if term.blank?
        scoped_resource
      else
        search_results
      end
    end

    private

    def search_results
      @association_search_joined = false
      searchable_attributes = dashboard.search_attributes
      return scoped_resource if searchable_attributes.empty?

      conditions = searchable_attributes.map do |attr|
        type = dashboard.attribute_type_for(attr)

        if type.respond_to?(:associative?) && type.associative?
          build_association_search(attr, type)
        else
          table = scoped_resource.model.arel_table
          table[attr].matches("%#{sanitize(term)}%")
        end
      end.compact

      return scoped_resource if conditions.empty?

      combined = conditions.reduce(:or)
      results = scoped_resource.where(combined)
      @association_search_joined ? results.distinct : results
    end

    def build_association_search(attr, type)
      reflection = scoped_resource.model.reflect_on_association(attr)
      return nil unless reflection

      assoc_table = reflection.klass.arel_table
      columns = association_search_columns(type, reflection.klass)
      return nil if columns.empty?

      @scoped_resource = scoped_resource.left_joins(attr)
      @association_search_joined = true
      columns
        .map { |column| assoc_table[column].matches("%#{sanitize(term)}%") }
        .reduce(:or)
    end

    def association_search_columns(type, associated_class)
      configured = type.respond_to?(:options) ? Array(type.options[:searchable_fields]) : []
      candidates = configured.presence || [:name, :title, :email]
      column_names = associated_class.column_names

      candidates
        .map(&:to_s)
        .select { |column| column_names.include?(column) }
        .map(&:to_sym)
    end

    def sanitize(term)
      term.gsub(/[%_\\]/) { |m| "\\#{m}" }
    end
  end
end
