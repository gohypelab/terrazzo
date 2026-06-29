module Terrazzo
  module ResourcePathsHelper
    def terrazzo_resource_collection_path(resource_or_class = resource_class)
      url_for(
        controller: terrazzo_resource_controller_path(resource_or_class),
        action: :index,
        only_path: true,
        format: nil
      )
    rescue ActionController::UrlGenerationError
      nil
    end

    def terrazzo_resource_new_path(resource_or_class = resource_class)
      url_for(
        controller: terrazzo_resource_controller_path(resource_or_class),
        action: :new,
        only_path: true,
        format: nil
      )
    rescue ActionController::UrlGenerationError
      nil
    end

    def terrazzo_resource_member_path(resource, action: :show)
      return nil unless resource.respond_to?(:id) && resource.id.present?

      route_action = action.to_sym == :destroy ? :show : action
      url_for(
        controller: terrazzo_resource_controller_path(resource),
        action: route_action,
        id: terrazzo_resource_param(resource),
        only_path: true,
        format: nil
      )
    rescue ActionController::UrlGenerationError
      nil
    end

    # The URL parameter used to identify a member resource. Defaults to the
    # record id. Override in a host app (e.g. to `resource.to_param`) to route
    # members by slug or another identifier; the matching lookup belongs in the
    # controller's #find_resource.
    def terrazzo_resource_param(resource)
      resource.id
    end

    def terrazzo_resource_controller_path(resource_or_class)
      klass = resource_or_class.is_a?(Class) ? resource_or_class : resource_or_class.class
      route_path = klass.model_name.name.underscore.pluralize

      [namespace, route_path].compact.join("/")
    end
  end
end
