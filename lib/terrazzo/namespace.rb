require_relative "namespace/resource"

module Terrazzo
  class Namespace
    attr_reader :name, :router

    def initialize(name, router = Rails.application.routes.router)
      @name = name.to_sym
      @router = router
    end

    def resources
      routes_for_namespace.map do |route|
        Resource.new(route)
      end.uniq(&:resource_name)
    end

    def resources_with_index_route
      routes_for_namespace.select do |route|
        route.defaults[:action] == "index"
      end.map { |route| Resource.new(route) }.uniq(&:controller_path)
    end

    def navigation_resources
      resources_with_index_route
        .select(&:show_in_navigation?)
        .sort_by do |resource|
          [
            navigation_sort_value(resource.navigation_group_order),
            navigation_sort_value(resource.navigation_group),
            navigation_sort_value(resource.navigation_order),
            navigation_sort_value(resource.navigation_label),
          ]
        end
    end

    private

    def routes_for_namespace
      namespace_routes.select do |route|
        path = route.defaults[:controller].to_s
        path.start_with?("#{name}/") &&
          route.defaults[:action].present?
      end
    end

    def namespace_routes
      if router.respond_to?(:routes) && !router.equal?(Rails.application.routes.router)
        router.routes
      else
        Rails.application.routes.routes
      end
    end

    def navigation_sort_value(value)
      value.is_a?(Numeric) ? [0, value] : [1, value.to_s]
    end
  end
end
