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
