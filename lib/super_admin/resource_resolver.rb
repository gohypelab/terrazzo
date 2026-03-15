module SuperAdmin
  class ResourceResolver
    attr_reader :controller_path

    def initialize(controller_path)
      @controller_path = controller_path
    end

    def dashboard_class
      "#{resource_class_name}Dashboard".constantize
    end

    def resource_class
      resource_class_name.constantize
    end

    def namespace
      parts = controller_path.split("/")
      parts.first.to_sym if parts.length > 1
    end

    def resource_title
      resource_class.model_name.human
    end

    private

    def resource_class_name
      parts = controller_path.split("/")
      resource_part = parts.last
      if parts.length > 2
        # Nested namespace like admin/blog/posts -> Blog::Post
        parts[1..-1].map { |p| p.classify }.join("::")
          .singularize
      else
        resource_part.classify
      end
    end
  end
end
