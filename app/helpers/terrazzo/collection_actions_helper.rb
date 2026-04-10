module Terrazzo
  module CollectionActionsHelper
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
        format: nil
      )
      {
        prevPagePath: (field.current_page > 1 ? url_for(base.merge(param_key => field.current_page - 1)) : nil),
        nextPagePath: (field.current_page < field.total_pages ? url_for(base.merge(param_key => field.current_page + 1)) : nil)
      }
    end

    private

    def default_collection_item_actions(resource)
      actions = []
      actions << { label: "Show", url: polymorphic_path([namespace, resource]) } rescue nil
      actions << { label: "Edit", url: edit_polymorphic_path([namespace, resource]) } rescue nil
      actions << { label: "Destroy", url: polymorphic_path([namespace, resource]), method: "delete", confirm: "Are you sure?" } rescue nil
      actions.compact
    end
  end
end
