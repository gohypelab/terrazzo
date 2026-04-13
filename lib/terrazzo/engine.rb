module Terrazzo
  class Engine < ::Rails::Engine
    isolate_namespace Terrazzo

    initializer "terrazzo.props_searcher_partial" do
      Props::Searcher.class_eval do
        def partial!(**options)
          @context.render options
        end
      end
    end

    initializer "terrazzo.i18n" do
      Terrazzo::Engine.root.glob("config/locales/**/*.yml").each do |locale|
        I18n.load_path << locale unless I18n.load_path.include?(locale)
      end
    end

    # Prevent Superglue's auto-include since Terrazzo handles controller
    # setup explicitly. This also avoids a load-order issue where
    # Superglue's scaffold controller generator triggers a require of
    # rails/generators/model_helpers before ActiveSupport core extensions
    # are available (mattr_accessor undefined on Ruby 4.0+).
    initializer "terrazzo.configure_superglue", before: "superglue" do |app|
      app.config.superglue = ActiveSupport::OrderedOptions.new unless app.config.respond_to?(:superglue)
      app.config.superglue.auto_include = false
    end

    initializer "terrazzo.uses_superglue" do
      ActiveSupport.on_load(:action_controller_base) do
        extend Terrazzo::UsesSuperglue
      end
    end
  end
end
