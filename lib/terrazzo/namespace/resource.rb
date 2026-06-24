module Terrazzo
  class Namespace
    class Resource
      attr_reader :route

      def initialize(route)
        @route = route
      end

      def resource_name
        controller_path.split("/").last
      end

      def controller_path
        route.defaults[:controller]
      end

      def to_s
        resource_name
      end

      def to_sym
        resource_name.to_sym
      end

      def dashboard
        @dashboard ||= dashboard_class&.new
      end

      def dashboard_class
        Terrazzo::ResourceResolver.new(controller_path).dashboard_class
      rescue NameError
        nil
      end

      def navigation_label
        dashboard&.navigation_label || resource_name.humanize.pluralize
      end

      def navigation_group
        dashboard&.navigation_group || "Resources"
      end

      def navigation_order
        dashboard&.navigation_order || navigation_label
      end

      def navigation_group_order
        dashboard&.navigation_group_order || navigation_group
      end

      def show_in_navigation?
        dashboard.nil? || dashboard.show_in_navigation?
      end

      def ==(other)
        resource_name == other.resource_name
      end

      def eql?(other)
        resource_name == other.resource_name
      end

      def hash
        resource_name.hash
      end
    end
  end
end
