require "json"
require "rails/generators"

module Terrazzo
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      FRONTEND_DEPENDENCIES = %w[
        terrazzo
        react
        react-dom
        react-redux
        @reduxjs/toolkit
        @thoughtbot/superglue
        @radix-ui/react-avatar
        @radix-ui/react-dialog
        @radix-ui/react-dropdown-menu
        @radix-ui/react-label
        @radix-ui/react-popover
        @radix-ui/react-select
        @radix-ui/react-separator
        @radix-ui/react-slot
        @radix-ui/react-tooltip
        class-variance-authority
        lucide-react
        tailwindcss
      ].freeze
      SUPPORTED_BUNDLERS = %w[vite esbuild].freeze

      argument :namespace_argument, type: :string, required: false,
        desc: "Admin namespace. Prefer --namespace; this positional form is kept for compatibility."

      class_option :namespace, type: :string, default: "admin",
        desc: "Admin namespace"
      class_option :bundler, type: :string, default: "vite",
        desc: "JavaScript bundler (vite or esbuild)"

      def validate_bundler
        return if SUPPORTED_BUNDLERS.include?(options[:bundler])

        raise Thor::Error, <<~MESSAGE
          Unsupported bundler '#{options[:bundler]}'.

          Terrazzo generates React/JSX admin views and supports Vite or esbuild.
          Re-run with `--bundler=vite` or `--bundler=esbuild`.
        MESSAGE
      end

      def validate_namespace
        return if namespace_argument.blank?
        return if options[:namespace] == "admin" || options[:namespace] == namespace_argument

        raise Thor::Error, <<~MESSAGE
          Conflicting admin namespaces: '#{namespace_argument}' and '#{options[:namespace]}'.

          Use either `rails generate terrazzo:install #{namespace_argument}` or
          `rails generate terrazzo:install --namespace=#{options[:namespace]}`, not both.
        MESSAGE
      end

      def verify_database_schema
        models = application_models
        raise_no_models_error if models.empty?

        missing_tables = models.reject { |model| table_exists_for?(model) }
        return if missing_tables.empty?

        model_names = missing_tables.map(&:name).join(", ")
        raise Thor::Error, <<~MESSAGE
          Terrazzo could not generate dashboards because these models do not have database tables: #{model_names}

          Run `bin/rails db:prepare` first, then run `bin/rails generate terrazzo:install` again.
        MESSAGE
      end

      def create_application_controller
        template "application_controller.rb.erb",
          "app/controllers/#{namespace_name}/application_controller.rb"
      end

      def create_layout
        template "superglue.html.erb.erb",
          "app/views/layouts/#{namespace_name}/application.html.erb"
      end

      def create_json_props_layout
        template "application.json.props.tt",
          "app/views/layouts/#{namespace_name}/application.json.props"
      end

      def create_js_entry_point
        template "application.js.erb",
          "app/javascript/#{namespace_name}/application.jsx"
      end

      def create_esbuild_entry_point
        return unless esbuild?

        create_file "app/javascript/#{namespace_name}.js",
          %(import "./#{namespace_name}/application.jsx"\n)
      end

      def create_store
        template "store.js.erb",
          "app/javascript/#{namespace_name}/store.js"
      end

      def create_page_to_page_mapping
        template "page_to_page_mapping.js.erb",
          "app/javascript/#{namespace_name}/page_to_page_mapping.js"
      end

      def create_generated_page_mapping
        template "generated_page_mapping.js.erb",
          "app/javascript/#{namespace_name}/generated_page_mapping.js"
      end

      def create_custom_page_mapping
        template "custom_page_mapping.js.erb",
          "app/javascript/#{namespace_name}/custom_page_mapping.js"
      end

      def create_application_visit
        template "application_visit.js.erb",
          "app/javascript/#{namespace_name}/application_visit.js"
      end

      def create_flash_slice
        template "flash_slice.js.erb",
          "app/javascript/#{namespace_name}/slices/flash.js"
      end

      def create_stylesheet
        copy_file "admin.css",
          "app/assets/stylesheets/#{namespace_name}.css"
      end

      def create_components_json
        if File.exist?(File.join(destination_root, "components.json"))
          say_status :skip, "components.json already exists", :yellow
          return
        end

        template "components.json.erb", "components.json"
      end

      def create_jsconfig
        if File.exist?(File.join(destination_root, "jsconfig.json"))
          say_status :skip, "jsconfig.json already exists", :yellow
          return
        end

        if File.exist?(File.join(destination_root, "tsconfig.json"))
          say_status :skip, "tsconfig.json already exists", :yellow
          return
        end

        copy_file "jsconfig.json", "jsconfig.json"
      end

      def run_views_generator
        generate "terrazzo:views", "--namespace=#{namespace_name}"
      end

      def run_routes_generator
        generate "terrazzo:routes", "--namespace=#{namespace_name}"
      end

      def run_dashboard_generators
        application_models.each do |model|
          generate "terrazzo:dashboard", model.name, "--namespace=#{namespace_name}", "--bundler=#{options[:bundler]}"
        end
      end

      def verify_frontend_dependencies
        missing = missing_frontend_dependencies
        return if missing.empty?

        say_status :warning, "Missing frontend dependencies required by Terrazzo:", :yellow
        say "  #{missing.join(" ")}"
        say "Run: #{frontend_install_command(missing)}"
      end

      def verify_tailwind_build_pipeline
        return if tailwind_build_pipeline?

        say_status :warning, "Terrazzo generated app/assets/stylesheets/#{namespace_name}.css but no Tailwind build pipeline was detected.", :yellow
        say "Make sure your app compiles that file with Tailwind before serving the admin UI."
        say "For package.json scripts, install the Tailwind CLI and add a build script:"
        say "  #{package_manager_add_dev_command} @tailwindcss/cli"
        say %(  "build:#{namespace_name}:css": "tailwindcss -i app/assets/stylesheets/#{namespace_name}.css -o app/assets/builds/#{namespace_name}.css --minify")
      end

      private

      def namespace_name
        namespace_argument.presence || options[:namespace]
      end

      def vite?
        options[:bundler] == "vite"
      end

      def esbuild?
        options[:bundler] == "esbuild"
      end

      def missing_frontend_dependencies
        installed = package_json_dependencies
        FRONTEND_DEPENDENCIES.reject { |package_name| installed.key?(package_name) }
      end

      def package_json_dependencies
        package_json_path = File.join(destination_root, "package.json")
        return {} unless File.exist?(package_json_path)

        package_json = parsed_package_json
        %w[dependencies devDependencies peerDependencies optionalDependencies]
          .each_with_object({}) do |section, dependencies|
            dependencies.merge!(package_json.fetch(section, {}))
          end
      rescue JSON::ParserError
        {}
      end

      def package_json_scripts
        parsed_package_json.fetch("scripts", {})
      rescue JSON::ParserError
        {}
      end

      def parsed_package_json
        @package_json ||= begin
          package_json_path = File.join(destination_root, "package.json")
          File.exist?(package_json_path) ? JSON.parse(File.read(package_json_path)) : {}
        end
      end

      def frontend_install_command(packages)
        "#{package_manager_add_command} #{packages.join(" ")}"
      end

      def package_manager_add_command
        return "pnpm add" if File.exist?(File.join(destination_root, "pnpm-lock.yaml"))
        return "yarn add" if File.exist?(File.join(destination_root, "yarn.lock"))
        return "bun add" if File.exist?(File.join(destination_root, "bun.lock")) ||
          File.exist?(File.join(destination_root, "bun.lockb"))

        "npm install"
      end

      def package_manager_add_dev_command
        return "pnpm add -D" if File.exist?(File.join(destination_root, "pnpm-lock.yaml"))
        return "yarn add -D" if File.exist?(File.join(destination_root, "yarn.lock"))
        return "bun add -d" if File.exist?(File.join(destination_root, "bun.lock")) ||
          File.exist?(File.join(destination_root, "bun.lockb"))

        "npm install --save-dev"
      end

      def tailwind_build_pipeline?
        tailwind_package_script? ||
          tailwind_vite_plugin? ||
          tailwind_rails_gem?
      end

      def tailwind_package_script?
        package_json_scripts.any? do |_name, command|
          command = command.to_s
          command.include?("tailwindcss") && command.include?(admin_stylesheet_path)
        end
      end

      def tailwind_vite_plugin?
        dependencies = package_json_dependencies
        dependencies.key?("@tailwindcss/vite")
      end

      def admin_stylesheet_path
        "app/assets/stylesheets/#{namespace_name}.css"
      end

      def tailwind_rails_gem?
        %w[Gemfile Gemfile.lock].any? do |file_name|
          path = File.join(destination_root, file_name)
          File.exist?(path) && File.read(path).include?("tailwindcss-rails")
        end
      end

      def application_models
        models_path = Rails.root.join("app", "models")
        return [] unless models_path.exist?

        Dir[models_path.join("**", "*.rb")].filter_map do |file|
          relative = Pathname.new(file).relative_path_from(models_path).to_s
          next if relative.start_with?("concerns/")
          next if relative == "application_record.rb"

          relative.delete_suffix(".rb").camelize.safe_constantize
        end.select { |klass| klass < ApplicationRecord && !klass.abstract_class? }
      end

      def table_exists_for?(model)
        model.table_exists?
      rescue ActiveRecord::ConnectionNotEstablished,
        ActiveRecord::NoDatabaseError,
        ActiveRecord::StatementInvalid
        false
      end

      def raise_no_models_error
        raise Thor::Error, <<~MESSAGE
          Terrazzo could not find any ApplicationRecord models to generate dashboards.

          Add at least one model first, then run `bin/rails generate terrazzo:install` again.
        MESSAGE
      end
    end
  end
end
