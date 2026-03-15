require "rails/generators"

module SuperAdmin
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      class_option :namespace, type: :string, default: "admin",
        desc: "Admin namespace"

      def copy_ui_components
        directory "components/ui", "app/views/#{namespace_name}/components/ui"
      end

      def copy_shared_components
        %w[
          Layout.jsx
          app-sidebar.jsx
          site-header.jsx
          FlashMessages.jsx
          SearchBar.jsx
          Pagination.jsx
          SortableHeader.jsx
        ].each do |file|
          copy_file "components/#{file}", "app/views/#{namespace_name}/components/#{file}"
        end
      end

      def copy_page_templates
        {
          "pages/index.jsx" => "application/index.jsx",
          "pages/show.jsx" => "application/show.jsx",
          "pages/new.jsx" => "application/new.jsx",
          "pages/edit.jsx" => "application/edit.jsx",
          "pages/_form.jsx" => "application/_form.jsx",
        }.each do |src, dest|
          copy_file src, "app/views/#{namespace_name}/#{dest}"
        end
      end

      def copy_field_components
        directory "fields", "app/views/#{namespace_name}/fields"
      end

      private

      def namespace_name
        options[:namespace]
      end
    end
  end
end
