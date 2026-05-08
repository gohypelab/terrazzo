module Terrazzo
  module CollectionActionsHelper
    DEFAULT_COLLECTION_ACTIONS = [
      { action: :show, label: "Show", route: :polymorphic_path },
      { action: :edit, label: "Edit", route: :edit_polymorphic_path },
      {
        action: :destroy,
        label: "Destroy",
        route: :polymorphic_path,
        method: "delete",
        confirm: "Are you sure?"
      }
    ].freeze

    def collection_item_actions(resource)
      resource_dashboard = "#{resource.class.name}Dashboard".safe_constantize&.new
      if resource_dashboard&.respond_to?(:collection_item_actions)
        resource_dashboard.collection_item_actions(resource, self)
      else
        default_collection_item_actions(resource)
      end
    end

    def has_many_pagination_paths(field, resource)
      param_key = Terrazzo::HasManyPagination.param_key(field.attribute)
      base = request.query_parameters.merge(
        only_path: true,
        controller: controller_path,
        action: :show,
        id: resource.to_param,
        format: nil,
        props_at: "data.attributes.#{field.attribute}"
      )
      {
        prevPagePath: (field.current_page > 1 ? url_for(base.merge(param_key => field.current_page - 1)) : nil),
        nextPagePath: (field.current_page < field.total_pages ? url_for(base.merge(param_key => field.current_page + 1)) : nil)
      }
    end

    private

    def default_collection_item_actions(resource)
      DEFAULT_COLLECTION_ACTIONS.filter_map do |action|
        url = public_send(action[:route], [namespace, resource])
        next unless route_resolves_to_action?(url, action[:action], action.fetch(:method, "get"))

        action.except(:action, :route).merge(url: url)
      rescue ActionController::RoutingError, ActionController::UrlGenerationError, NoMethodError
        nil
      end
    end

    def route_resolves_to_action?(path, action, method)
      Rails.application.routes.recognize_path(path, method: method)[:action] == action.to_s
    end
  end
end
