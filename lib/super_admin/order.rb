module SuperAdmin
  class Order
    attr_reader :attribute, :direction

    VALID_DIRECTIONS = %w[asc desc].freeze

    def initialize(attribute: nil, direction: nil)
      @attribute = attribute&.to_sym
      @direction = normalize_direction(direction)
    end

    def apply(relation, dashboard)
      return relation unless attribute

      type = dashboard.attribute_type_for(attribute)

      return relation if type.respond_to?(:sortable?) && !type.sortable?

      if type.respond_to?(:associative?) && type.associative?
        order_by_association(relation, type)
      else
        relation
          .order(attribute => direction)
          .order(relation.model.primary_key => :asc)
      end
    end

    def order_params_for(attr)
      new_direction = if attr.to_sym == attribute
        direction == :asc ? :desc : :asc
      else
        :asc
      end

      { order: attr.to_s, direction: new_direction.to_s }
    end

    def ordered_by?(attr)
      attribute == attr.to_sym
    end

    private

    def normalize_direction(dir)
      dir = dir.to_s.downcase
      VALID_DIRECTIONS.include?(dir) ? dir.to_sym : :asc
    end

    def order_by_association(relation, type)
      reflection = relation.model.reflect_on_association(attribute)
      return relation unless reflection

      if reflection.macro == :has_many
        relation
          .left_joins(attribute)
          .group(relation.model.primary_key)
          .order(Arel.sql("COUNT(#{reflection.klass.table_name}.id) #{direction}"))
      else
        name_column = [:name, :title, :email].find { |col| reflection.klass.column_names.include?(col.to_s) }
        if name_column
          relation
            .left_joins(attribute)
            .order("#{reflection.klass.table_name}.#{name_column} #{direction}")
            .order(relation.model.primary_key => :asc)
        else
          relation
        end
      end
    end
  end
end
