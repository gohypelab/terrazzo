require "superglue"

module Terrazzo
  class ApplicationController < ::ActionController::Base
    include Superglue::Controller
    include Terrazzo::ResourcePathsHelper

    prepend_view_path(
      Superglue::Resolver.new(Terrazzo::Engine.root.join("app/views"))
    )

    prepend_view_path(
      Superglue::Resolver.new(Rails.root.join("app/views"))
    )

    before_action :use_jsx_rendering_defaults

    prepend Terrazzo::UsesSuperglue::TemplateLookupOverride

    helper_method :namespace, :dashboard, :resource_name, :resource_class, :application_title, :terrazzo_page_identifier, :route_exists?, :authorized_action?
    helper Terrazzo::CollectionActionsHelper
    helper Terrazzo::ResourcePathsHelper

    def index
      resources, order = index_resources_and_order

      if request.format.csv?
        return head :not_acceptable unless dashboard.csv_export_enabled?

        includes = dashboard.includes_for_attributes(dashboard.csv_attributes)
        resources = resources.includes(*includes) if includes.any?

        send_data Terrazzo::CsvExport.new(dashboard, resources).to_csv,
          filename: dashboard.csv_filename,
          type: "text/csv; charset=utf-8"
        return
      end

      includes = dashboard.collection_includes
      resources = resources.includes(*includes) if includes.any?

      @resources = resources.page(params[:_page]).per(params[:per_page] || 25)
      @page = Terrazzo::Page::Collection.new(dashboard, resource_class, order: order)
      @search_term = params[:search]
      @active_filter = params[:filter]
      @filter_value = params[:filter_value]
    end

    def show
      @resource = find_resource(params[:id])
      authorize_action!(@resource, :show)
      @page = Terrazzo::Page::Show.new(
        dashboard, @resource,
        has_many_params: Terrazzo::HasManyPagination.extract(params, dashboard.has_many_attributes)
      )
    end

    def new
      @resource = resource_class.new
      authorize_action!(@resource, :new)
      @page = Terrazzo::Page::Form.new(dashboard, @resource)
    end

    def edit
      @resource = find_resource(params[:id])
      authorize_action!(@resource, :edit)
      @page = Terrazzo::Page::Form.new(dashboard, @resource)
    end

    def create
      @resource = resource_class.new
      authorize_action!(@resource, :create)
      @resource.assign_attributes(resource_params("create"))
      assign_has_one_associations(@resource)

      if @resource.save
        redirect_to after_resource_created_path(@resource),
          notice: t("terrazzo.controllers.create.success",
            resource_name: resource_name)
      else
        @page = Terrazzo::Page::Form.new(dashboard, @resource)
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @resource = find_resource(params[:id])
      authorize_action!(@resource, :update)

      rp = resource_params("update")
      assign_has_one_associations(@resource)

      if @resource.update(rp)
        redirect_to after_resource_updated_path(@resource),
          notice: t("terrazzo.controllers.update.success",
            resource_name: resource_name)
      else
        @page = Terrazzo::Page::Form.new(dashboard, @resource)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @resource = find_resource(params[:id])
      authorize_action!(@resource, :destroy)
      @resource.destroy

      redirect_to after_resource_destroyed_path,
        notice: t("terrazzo.controllers.destroy.success",
          resource_name: resource_name)
    end

    protected

    def application_title
      Rails.application.class.module_parent_name.titleize
    end

    def default_sorting_attribute
      nil
    end

    def default_sorting_direction
      :asc
    end

    def after_resource_created_path(resource)
      terrazzo_resource_member_path(resource) || after_resource_destroyed_path
    end

    def after_resource_updated_path(resource)
      terrazzo_resource_member_path(resource) || after_resource_destroyed_path
    end

    def after_resource_destroyed_path
      url_for(action: :index, only_path: true)
    rescue ActionController::UrlGenerationError
      "/"
    end

    def scoped_resource
      resource_class.all
    end

    def index_resources_and_order
      search = Terrazzo::Search.new(scoped_resource, dashboard, params[:search])
      resources = search.run

      filter = Terrazzo::Filter.new(resources, dashboard, params[:filter], params[:filter_value])
      resources = filter.run

      order = Terrazzo::Order.new(
        attribute: params[:order] || default_sorting_attribute,
        direction: params[:direction] || (params[:order] ? nil : default_sorting_direction)
      )
      resources = order.apply(resources, dashboard)

      [resources, order]
    end

    def find_resource(id)
      @_find_resource ||= scoped_resource.find(id)
    end

    def resource_params(action = nil)
      permitted = params.require(resource_class.model_name.param_key)
        .permit(dashboard.permitted_attributes(action))

      # Transform and extract special field params
      @has_one_assignments = {}
      dashboard.flatten_attributes(dashboard.form_attributes(action)).each do |attr|
        field_type = dashboard.attribute_type_for(attr)
        klass = field_type.is_a?(Terrazzo::Field::Deferred) ? field_type.deferred_class : field_type

        # Transform params (e.g., JSON string → Hash for hstore fields)
        if permitted.key?(attr.to_s) && klass.respond_to?(:transform_param)
          permitted[attr.to_s] = klass.transform_param(permitted[attr.to_s])
        end

        # Extract has_one virtual _id params since ActiveRecord doesn't
        # natively support assigning has_one associations by id
        next unless klass <= Terrazzo::Field::HasOne

        id_key = "#{attr}_id"
        if permitted.key?(id_key)
          id_value = permitted.delete(id_key)
          @has_one_assignments[attr] = id_value if id_value.present?
        end
      end

      permitted
    end

    def assign_has_one_associations(resource)
      return unless @has_one_assignments

      @has_one_assignments.each do |attr, id_value|
        reflection = resource.class.reflect_on_association(attr)
        associated = reflection.klass.find(id_value)
        resource.public_send(:"#{attr}=", associated)
      end
    end

    def authorized_action?(resource, action)
      true
    end

    def authorize_action!(resource, action)
      return if authorized_action?(resource, action)

      raise Terrazzo::NotAuthorizedError
    end

    def namespace
      @_namespace ||= resolver.namespace
    end

    def dashboard
      @_dashboard ||= resolver.dashboard_class.new
    end

    def resource_class
      @_resource_class ||= resolver.resource_class
    end

    def resource_name
      @_resource_name ||= resolver.resource_title
    end

    # Build a page identifier for the React page-to-component mapping.
    # Returns a resource-specific identifier (e.g. "admin/orders/index")
    # which the JS mapping resolves with fallback to "admin/application/index".
    #
    # Map create → new and update → edit so that failed validations
    # (which render :new / :edit) resolve to the correct React component.
    TERRAZZO_ACTION_MAP = { "create" => "new", "update" => "edit" }.freeze

    def terrazzo_page_identifier
      mapped_action = TERRAZZO_ACTION_MAP[action_name] || action_name
      "#{controller_path}/#{mapped_action}"
    end

    def route_exists?(action)
      @_route_exists_cache ||= {}
      return @_route_exists_cache[action] if @_route_exists_cache.key?(action)

      @_route_exists_cache[action] = Rails.application.routes.routes.any? do |route|
        route.defaults[:controller] == controller_path &&
          route.defaults[:action] == action.to_s
      end
    end

    private

    def resolver
      @_resolver ||= Terrazzo::ResourceResolver.new(controller_path)
    end
  end
end
