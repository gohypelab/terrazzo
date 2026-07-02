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

    # The URL parameter used to identify a member resource in generated
    # show/edit/destroy links. Defaults to `to_param` so host apps that route
    # members by slug (or any other `to_param` scheme) get correct links without
    # overriding this hook, mirroring the `polymorphic_path` behavior Terrazzo
    # relied on before it built these paths manually. When `to_param` returns
    # something other than the primary key, `#find_resource` (default:
    # `scoped_resource.find(id)`) must be overridden in tandem or the generated
    # links will 404.
    def terrazzo_resource_param(resource)
      resource.to_param
    end

    def terrazzo_resource_controller_path(resource_or_class)
      klass = resource_or_class.is_a?(Class) ? resource_or_class : resource_or_class.class
      route_path = klass.model_name.name.underscore.pluralize

      [namespace, route_path].compact.join("/")
    end
  end
end
