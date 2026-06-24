require "csv"
require "json"

module Terrazzo
  class CsvExport
    attr_reader :dashboard, :resources

    def initialize(dashboard, resources)
      @dashboard = dashboard
      @resources = resources
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << attributes.map { |attr| header_for(attr) }

        resources.each do |resource|
          csv << attributes.map { |attr| value_for(resource, attr) }
        end
      end
    end

    private

    def attributes
      @attributes ||= dashboard.flatten_attributes(dashboard.csv_attributes)
    end

    def header_for(attribute)
      dashboard.attribute_label(attribute, :csv)
    end

    def value_for(resource, attribute)
      field = dashboard.attribute_type_for(attribute).new(attribute, nil, :index, resource: resource)
      dashboard.csv_value(attribute, field.serialize_value(:index), resource)
    end
  end
end
