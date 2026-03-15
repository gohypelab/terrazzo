require "superglue"

module SuperAdmin
  class ApplicationController < ::ActionController::Base
    include Superglue::Controller

    prepend_view_path(
      Superglue::Resolver.new(SuperAdmin::Engine.root.join("app/views"))
    )

    prepend_view_path(
      Superglue::Resolver.new(Rails.root.join("app/views"))
    )

    layout "admin/application"
    superglue_template "admin/application"
    before_action :use_jsx_rendering_defaults

    helper_method :namespace, :dashboard, :resource_name, :resource_class, :application_title

    def index
      search = SuperAdmin::Search.new(scoped_resource, dashboard, params[:search])
      resources = search.run

      filter = SuperAdmin::Filter.new(resources, dashboard, params[:filter], params[:filter_value])
      resources = filter.run

      order = SuperAdmin::Order.new(
        attribute: params[:order] || default_sorting_attribute,
        direction: params[:direction] || (params[:order] ? nil : default_sorting_direction)
      )
      resources = order.apply(resources, dashboard)

      includes = dashboard.collection_includes
      resources = resources.includes(*includes) if includes.any?

      @resources = resources.page(params[:_page]).per(params[:per_page] || 20)
      @page = SuperAdmin::Page::Collection.new(dashboard, resource_class, order: order)
      @search_term = params[:search]
      @active_filter = params[:filter]
      @filter_value = params[:filter_value]
    end

    def show
      @resource = find_resource(params[:id])
      @page = SuperAdmin::Page::Show.new(dashboard, @resource)
    end

    def new
      @resource = resource_class.new
      @page = SuperAdmin::Page::Form.new(dashboard, @resource)
    end

    def edit
      @resource = find_resource(params[:id])
      @page = SuperAdmin::Page::Form.new(dashboard, @resource)
    end

    def create
      @resource = resource_class.new(resource_params("create"))
      assign_has_one_associations(@resource)

      if @resource.save
        redirect_to after_resource_created_path(@resource),
          notice: t("super_admin.controllers.create.success",
            resource_name: resource_name)
      else
        @page = SuperAdmin::Page::Form.new(dashboard, @resource)
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @resource = find_resource(params[:id])

      rp = resource_params("update")
      assign_has_one_associations(@resource)

      if @resource.update(rp)
        redirect_to after_resource_updated_path(@resource),
          notice: t("super_admin.controllers.update.success",
            resource_name: resource_name)
      else
        @page = SuperAdmin::Page::Form.new(dashboard, @resource)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @resource = find_resource(params[:id])
      @resource.destroy

      redirect_to after_resource_destroyed_path,
        notice: t("super_admin.controllers.destroy.success",
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
      [namespace, resource]
    end

    def after_resource_updated_path(resource)
      [namespace, resource]
    end

    def after_resource_destroyed_path
      url_for(action: :index, only_path: true)
    rescue ActionController::UrlGenerationError
      "/"
    end

    def scoped_resource
      resource_class.all
    end

    def find_resource(id)
      scoped_resource.find(id)
    rescue ActiveRecord::RecordNotFound
      # Support models that override to_param (e.g., slug-based URLs)
      scoped_resource.find_by!(slug: id)
    end

    def resource_params(action = nil)
      permitted = params.require(resource_class.model_name.param_key)
        .permit(dashboard.permitted_attributes(action))

      # Transform and extract special field params
      @has_one_assignments = {}
      dashboard.flatten_attributes(dashboard.form_attributes(action)).each do |attr|
        field_type = dashboard.attribute_type_for(attr)
        klass = field_type.is_a?(SuperAdmin::Field::Deferred) ? field_type.deferred_class : field_type

        # Transform params (e.g., JSON string → Hash for hstore fields)
        if permitted.key?(attr.to_s) && klass.respond_to?(:transform_param)
          permitted[attr.to_s] = klass.transform_param(permitted[attr.to_s])
        end

        # Extract has_one virtual _id params since ActiveRecord doesn't
        # natively support assigning has_one associations by id
        next unless klass <= SuperAdmin::Field::HasOne

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

    private

    def resolver
      @_resolver ||= SuperAdmin::ResourceResolver.new(controller_path)
    end
  end
end
