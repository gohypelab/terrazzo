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

    private

    def routes_for_namespace
      Rails.application.routes.routes.select do |route|
        path = route.defaults[:controller].to_s
        path.start_with?("#{name}/") &&
          route.defaults[:action].present?
      end
    end
  end
end
