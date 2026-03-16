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
      searchable_attributes = dashboard.search_attributes
      return scoped_resource if searchable_attributes.empty?

      conditions = searchable_attributes.map do |attr|
        type = dashboard.attribute_type_for(attr)

        if type.respond_to?(:associative?) && type.associative?
          build_association_search(attr)
        else
          table = scoped_resource.model.arel_table
          table[attr].matches("%#{sanitize(term)}%")
        end
      end.compact

      combined = conditions.reduce(:or)
      scoped_resource.where(combined)
    end

    def build_association_search(attr)
      reflection = scoped_resource.model.reflect_on_association(attr)
      return nil unless reflection

      assoc_table = reflection.klass.arel_table
      name_column = [:name, :title, :email].find { |col| reflection.klass.column_names.include?(col.to_s) }
      return nil unless name_column

      @scoped_resource = scoped_resource.left_joins(attr)
      assoc_table[name_column].matches("%#{sanitize(term)}%")
    end

    def sanitize(term)
      term.gsub(/[%_\\]/) { |m| "\\#{m}" }
    end
  end
end
