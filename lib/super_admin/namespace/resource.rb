module SuperAdmin
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
