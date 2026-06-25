module Terrazzo
  module CollectionActionsHelper
    def collection_item_actions(resource)
      resource_dashboard = "#{resource.class.name}Dashboard".safe_constantize&.new
      dashboard = resource_dashboard if resource_dashboard&.respond_to?(:collection_item_actions)
      dashboard ||= Terrazzo::BaseDashboard.new
      dashboard.collection_item_actions(resource, self)
    end

    def collection_action_path(resource, action = :show)
      return nil unless collection_action_route?(resource, action)
      return nil unless collection_action_authorized?(resource, action)

      terrazzo_resource_member_path(resource, action: action)
    end

    def has_many_pagination_paths(field, resource)
      param_key = Terrazzo::HasManyPagination.param_key(field.attribute)
      legacy_param_key = Terrazzo::HasManyPagination.legacy_param_key(field.attribute)
      query_parameters = request.query_parameters.except(
        param_key,
        param_key.to_sym,
        legacy_param_key,
        legacy_param_key.to_sym
      )
      base = query_parameters.merge(
        only_path: true,
        controller: controller_path,
        action: :show,
        id: resource.id,
        format: nil,
        props_at: "data.attributes.#{field.attribute}"
      )
      {
        prevPagePath: (field.current_page > 1 ? url_for(base.merge(param_key => field.current_page - 1)) : nil),
        nextPagePath: (field.current_page < field.total_pages ? url_for(base.merge(param_key => field.current_page + 1)) : nil)
      }
    end

    private

    def collection_action_route?(resource, action)
      path = terrazzo_resource_member_path(resource, action: action)
      return false unless path

      recognized = Rails.application.routes.recognize_path(path, method: collection_action_http_method(action))
      recognized[:controller] == terrazzo_resource_controller_path(resource) &&
        recognized[:action] == action.to_s
    rescue ActionController::RoutingError, ActionController::UrlGenerationError, NoMethodError
      false
    end

    def collection_action_http_method(action)
      action == :destroy ? :delete : :get
    end

    def collection_action_authorized?(resource, action)
      return true unless respond_to?(:authorized_action?, true)

      authorized_action?(resource, action)
    end
  end
end
