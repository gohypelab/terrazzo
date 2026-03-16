module Terrazzo
  class Filter
    attr_reader :resources, :dashboard, :filter_name, :filter_value

    def initialize(resources, dashboard, filter_name, filter_value = nil)
      @resources = resources
      @dashboard = dashboard
      @filter_name = filter_name&.to_sym
      @filter_value = filter_value
    end

    def run
      return resources unless filter_name

      filters = dashboard.collection_filters
      filter_lambda = filters[filter_name]
      return resources unless filter_lambda

      if filter_lambda.arity == 1 || (filter_lambda.arity < 0 && filter_value.nil?)
        filter_lambda.call(resources)
      else
        filter_lambda.call(resources, filter_value)
      end
    end
  end
end
