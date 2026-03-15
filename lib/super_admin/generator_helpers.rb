module SuperAdmin
  module GeneratorHelpers
    def dashboard_name_for(model)
      "#{model.name.gsub("::", "")}Dashboard"
    end

    def controller_name_for(model)
      model.name.tableize.gsub("/", "_")
    end

    def column_to_field_type(column)
      case column.type
      when :string
        if column.name.end_with?("_id")
          "Field::Number"
        elsif column.name.include?("email")
          "Field::Email"
        elsif column.name.include?("url") || column.name.include?("link")
          "Field::Url"
        elsif column.name.include?("password")
          "Field::Password"
        else
          "Field::String"
        end
      when :text then "Field::Text"
      when :integer, :float, :decimal then "Field::Number"
      when :boolean then "Field::Boolean"
      when :date then "Field::Date"
      when :datetime then "Field::DateTime"
      when :time then "Field::Time"
      else
        "Field::String"
      end
    end
  end
end
