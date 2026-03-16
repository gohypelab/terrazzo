module Terrazzo
  class Engine < ::Rails::Engine
    isolate_namespace Terrazzo

    initializer "terrazzo.i18n" do
      Terrazzo::Engine.root.glob("config/locales/**/*.yml").each do |locale|
        I18n.load_path << locale unless I18n.load_path.include?(locale)
      end
    end

  end
end
