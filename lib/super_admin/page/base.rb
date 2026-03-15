module SuperAdmin
  module Page
    class Base
      attr_reader :dashboard, :resource_class

      def initialize(dashboard, resource_class)
        @dashboard = dashboard
        @resource_class = resource_class
      end
    end
  end
end
