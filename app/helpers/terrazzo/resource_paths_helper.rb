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
        id: resource.id,
        only_path: true,
        format: nil
      )
    rescue ActionController::UrlGenerationError
      nil
    end

    def terrazzo_resource_controller_path(resource_or_class)
      klass = resource_or_class.is_a?(Class) ? resource_or_class : resource_or_class.class
      route_path = klass.model_name.name.underscore.pluralize

      [namespace, route_path].compact.join("/")
    end
  end
end
