module SuperAdmin
  class Engine < ::Rails::Engine
    isolate_namespace SuperAdmin

    initializer "super_admin.i18n" do
      SuperAdmin::Engine.root.glob("config/locales/**/*.yml").each do |locale|
        I18n.load_path << locale unless I18n.load_path.include?(locale)
      end
    end

  end
end
