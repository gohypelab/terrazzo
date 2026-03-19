# frozen_string_literal: true

module Terrazzo
  module UsesSuperglue
    # Prepended to fix a template shadowing problem.
    #
    # When a controller inherits a long view prefix chain (e.g. from Devise or
    # other engines), Superglue's _render_template calls template_exists? with
    # all those prefixes and may find a gem-supplied HTML template, causing it
    # to render the unstyled ERB instead of the React page. This override
    # restricts the template existence check to the app's own view path only.
    module TemplateLookupOverride
      def _render_template(options = {})
        if @_capture_options_before_render
          @_capture_options_before_render = false
          @_render_options = options
          _ensure_react_page!(options[:template], options[:prefixes])

          app_views = Rails.root.join("app/views").to_s
          app_resolver = view_paths.to_a.find { |vp| vp.to_s == app_views && !vp.is_a?(Superglue::Resolver) }
          prefixes = Array(options[:prefixes]).compact
          html_template_exist = app_resolver&.find_all(options[:template], prefixes, false, { formats: [:html], locale: [], handlers: [], variants: [] }, nil, [])&.any?
          if !html_template_exist
            super(options.merge(template: _superglue_template, prefixes: []))
          else
            super
          end
        else
          super
        end
      end
    end

    def uses_superglue
      include Superglue::Controller
      prepend_view_path(Superglue::Resolver.new(Rails.root.join("app/views")))
      before_action :use_jsx_rendering_defaults
      prepend TemplateLookupOverride
    end
  end
end
