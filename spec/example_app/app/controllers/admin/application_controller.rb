module Admin
  class ApplicationController < SuperAdmin::ApplicationController
    layout "admin/application"
    superglue_template "admin/application"

    # before_action :authenticate_admin

    # Override to limit which records are visible
    # def scoped_resource
    #   resource_class.all
    # end

    # Override to control access to actions
    # def authorized_action?(resource, action)
    #   true
    # end

    private

    # def authenticate_admin
    #   redirect_to root_path unless current_user&.admin?
    # end
  end
end
