require "json"
require "pathname"
require "rails/generators"
require "terrazzo/version"

module Terrazzo
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      TAILWIND_PACKAGE_NAME = "tailwindcss"
      TAILWIND_CLI_PACKAGE_NAME = "@tailwindcss/cli"
      TAILWIND_MINIMUM_VERSION = "4.0.0"

      FRONTEND_DEPENDENCIES = (
        %w[
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
        ] + [TAILWIND_PACKAGE_NAME]
      ).freeze
      FRONTEND_DEPENDENCY_MINIMUMS = {
        "terrazzo" => Terrazzo::VERSION,
        "react" => "18.0.0",
        "react-dom" => "18.0.0",
        "react-redux" => "8.0.0",
        "@reduxjs/toolkit" => "1.9.0",
        "@thoughtbot/superglue" => "1.0.0",
        "@radix-ui/react-avatar" => "1.0.0",
        "@radix-ui/react-dialog" => "1.0.0",
        "@radix-ui/react-dropdown-menu" => "2.0.0",
        "@radix-ui/react-label" => "2.0.0",
        "@radix-ui/react-popover" => "1.0.0",
        "@radix-ui/react-select" => "2.0.0",
        "@radix-ui/react-separator" => "1.0.0",
        "@radix-ui/react-slot" => "1.0.0",
        "@radix-ui/react-tooltip" => "1.0.0",
        "class-variance-authority" => "0.7.0",
        "lucide-react" => "0.300.0",
        TAILWIND_PACKAGE_NAME => TAILWIND_MINIMUM_VERSION,
      }.freeze
      VITE_FRONTEND_DEPENDENCIES = %w[
        vite
        vite-plugin-ruby
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

      def verify_vite_bundler
        return unless vite?

        unless vite_rails_installed? && parsed_vite_config
          raise Thor::Error, <<~MESSAGE
            Terrazzo is configured for Vite, but vite_rails is not installed and configured.

            Add `gem "vite_rails"` and run `bundle exec vite install` first, or re-run Terrazzo with `--bundler=esbuild`.
          MESSAGE
        end

        missing = missing_vite_frontend_dependencies
        return if missing.empty?

        raise Thor::Error, <<~MESSAGE
          Terrazzo is configured for Vite, but package.json is missing required Vite dependencies: #{missing.join(", ")}.

          Run `bundle exec vite install` successfully, install the generated package.json dependencies, or re-run Terrazzo with `--bundler=esbuild`.
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
        template "application.js.erb", js_entry_point_path
      end

      def create_vite_entry_point
        return unless vite?
        return if vite_entry_point_path == js_entry_point_path

        create_file vite_entry_point_path,
          %(import "#{relative_import_path(vite_entry_point_directory, js_entry_point_path)}"\n)
      end

      def configure_vite_watch_paths
        return unless vite?

        config = parsed_vite_config
        return unless config

        watch_paths = vite_watch_paths
        return if watch_paths.empty?

        config["all"] = {} unless config["all"].is_a?(Hash)
        existing_paths = Array(config["all"]["watchAdditionalPaths"])
        updated_paths = existing_paths | watch_paths
        return if updated_paths == existing_paths

        config["all"]["watchAdditionalPaths"] = updated_paths
        create_file "config/vite.json", "#{JSON.pretty_generate(config)}\n", force: true
      end

      def configure_vite_dev_server
        return unless vite?

        ensure_vite_procfile
        ensure_vite_bin_dev
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

      def create_tailwind_build_script
        return unless package_json_file?
        return if tailwind_build_pipeline?
        return unless tailwind_cli_package?
        return unless tailwind_cli_supported?

        package_json = parsed_package_json
        return if package_json.empty?

        scripts = package_json["scripts"]
        scripts = package_json["scripts"] = {} unless scripts.is_a?(Hash)
        return if scripts.key?(tailwind_build_script_name)

        scripts[tailwind_build_script_name] = tailwind_build_command
        create_file "package.json", "#{JSON.pretty_generate(package_json)}\n", force: true
      end

      def create_vite_build_script
        return unless vite?
        return unless package_json_file?

        package_json = parsed_package_json
        return if package_json.empty?

        scripts = package_json["scripts"]
        scripts = package_json["scripts"] = {} unless scripts.is_a?(Hash)
        return if scripts.key?("build")

        build_commands = ["vite build"]
        if scripts[tailwind_build_script_name] == tailwind_build_command
          build_commands << tailwind_build_command
        end

        scripts["build"] = build_commands.join(" && ")
        create_file "package.json", "#{JSON.pretty_generate(package_json)}\n", force: true
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
        outdated = outdated_frontend_dependencies

        if missing.any?
          say_status :warning, "Missing frontend dependencies required by Terrazzo:", :yellow
          say "  #{missing.join(" ")}"
          say "Run: #{frontend_install_command(missing)}"
        end

        return if outdated.empty?

        say_status :warning, "Frontend dependencies below Terrazzo's supported versions:", :yellow
        outdated.each do |dependency|
          say "  #{dependency[:name]} #{dependency[:requirement]} (requires >= #{dependency[:minimum]})"
        end
        say "Run: #{frontend_install_command(outdated.map { |dependency| "#{dependency[:name]}@latest" })}"
      end

      def verify_tailwind_build_pipeline
        if tailwind_cli_package? && !tailwind_cli_supported?
          say_status :warning, "Installed #{TAILWIND_CLI_PACKAGE_NAME} is below Terrazzo's supported version.", :yellow
          say "Terrazzo generated app/assets/stylesheets/#{namespace_name}.css with Tailwind #{TAILWIND_MINIMUM_VERSION}+ syntax."
          say "Run: #{package_manager_add_dev_command} #{TAILWIND_CLI_PACKAGE_NAME}@latest"
          return
        end

        return if tailwind_build_pipeline?

        say_status :warning, "Terrazzo generated app/assets/stylesheets/#{namespace_name}.css but no Tailwind build pipeline was detected.", :yellow
        say "Make sure your app compiles that file with Tailwind before serving the admin UI."
        say "For package.json scripts, install the Tailwind CLI and add a build script:"
        say "  #{package_manager_add_dev_command} #{TAILWIND_CLI_PACKAGE_NAME}@latest"
        say %(  "#{tailwind_build_script_name}": "#{tailwind_build_command}")
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

      def js_entry_point_path
        "app/javascript/#{namespace_name}/application.jsx"
      end

      def vite_entry_point_path
        clean_relative_path(File.join(vite_source_code_dir, vite_entrypoints_dir, namespace_name, "application.jsx"))
      end

      def vite_entry_point_tag_name
        clean_relative_path(File.join(vite_entrypoints_dir, namespace_name, "application.jsx"))
      end

      def vite_entry_point_directory
        File.dirname(vite_entry_point_path)
      end

      def vite_source_code_dir
        vite_config.fetch("sourceCodeDir", "app/frontend")
      end

      def vite_entrypoints_dir
        vite_config.fetch("entrypointsDir", "entrypoints")
      end

      def vite_config
        @vite_config ||= begin
          raw_config = parsed_vite_config || {}
          raw_config
            .merge(raw_config.fetch("all", {}))
            .merge(raw_config.fetch(vite_environment, {}))
        end
      end

      def vite_environment
        ENV["RAILS_ENV"].presence || ENV["RACK_ENV"].presence || "development"
      end

      def parsed_vite_config
        return nil unless vite_config_installed?

        JSON.parse(File.read(vite_config_path))
      rescue JSON::ParserError
        nil
      end

      def relative_import_path(from_directory, to_path)
        relative_path = Pathname
          .new(File.join(destination_root, to_path))
          .relative_path_from(Pathname.new(File.join(destination_root, from_directory)))
          .to_s

        relative_path.start_with?(".") ? relative_path : "./#{relative_path}"
      end

      def clean_relative_path(path)
        Pathname.new(path).cleanpath.to_s
      end

      def vite_watch_paths
        [
          "app/javascript/#{namespace_name}/**/*",
          "app/views/#{namespace_name}/**/*",
        ].select { |path| outside_vite_source_code_dir?(path) }
      end

      def outside_vite_source_code_dir?(path)
        source_dir = clean_relative_path(vite_source_code_dir)
        return false if source_dir == "."

        watched_root = clean_relative_path(path.delete_suffix("/**/*"))
        watched_root != source_dir && !watched_root.start_with?("#{source_dir}/")
      end

      def vite_config_installed?
        File.exist?(vite_config_path)
      end

      def vite_config_path
        File.join(destination_root, "config/vite.json")
      end

      def ensure_vite_procfile
        if File.exist?(procfile_dev_path)
          return if procfile_runs_vite?(File.read(procfile_dev_path))

          existing_content = File.read(procfile_dev_path)
          append_to_file "Procfile.dev",
            "#{existing_content.end_with?("\n") ? "" : "\n"}vite: bin/vite dev\n"
        else
          create_file "Procfile.dev", <<~PROCFILE
            web: bin/rails s
            vite: bin/vite dev
          PROCFILE
        end
      end

      def ensure_vite_bin_dev
        if File.exist?(bin_dev_path)
          content = File.read(bin_dev_path)
          return if bin_dev_runs_procfile?(content)

          unless default_rails_server_bin_dev?(content)
            say_status :warning, "bin/dev does not run Procfile.dev; start Vite with `bin/vite dev` or update bin/dev.", :yellow
            return
          end
        end

        create_file "bin/dev", vite_bin_dev_script, force: true
        File.chmod(0o755, bin_dev_path)
      end

      def procfile_dev_path
        File.join(destination_root, "Procfile.dev")
      end

      def bin_dev_path
        File.join(destination_root, "bin/dev")
      end

      def procfile_runs_vite?(content)
        content.match?(/^\s*[^#\n]+:\s*.*(?:bin\/)?vite\s+dev\b/)
      end

      def bin_dev_runs_procfile?(content)
        content.include?("Procfile.dev")
      end

      def default_rails_server_bin_dev?(content)
        content.include?('exec "./bin/rails", "server", *ARGV') ||
          content.match?(/exec\s+\.?\/?bin\/rails\s+(server|s)\b/)
      end

      def vite_bin_dev_script
        <<~SH
          #!/usr/bin/env sh

          if ! gem list foreman -i --silent; then
            echo "Installing foreman..."
            gem install foreman
          fi

          exec foreman start -f Procfile.dev "$@"
        SH
      end

      def vite_rails_installed?
        %w[Gemfile Gemfile.lock].any? do |file_name|
          path = File.join(destination_root, file_name)
          File.exist?(path) && File.read(path).include?("vite_rails")
        end
      end

      def missing_frontend_dependencies
        installed = package_json_dependencies
        FRONTEND_DEPENDENCIES.reject { |package_name| installed.key?(package_name) }
      end

      def outdated_frontend_dependencies
        installed = package_json_dependencies
        FRONTEND_DEPENDENCY_MINIMUMS.filter_map do |package_name, minimum|
          requirement = installed[package_name]
          next if requirement.nil?
          next if dependency_requirement_satisfies_minimum?(requirement, minimum)

          {
            name: package_name,
            requirement: requirement,
            minimum: minimum,
          }
        end
      end

      def dependency_requirement_satisfies_minimum?(requirement, minimum)
        requirement = requirement.to_s.strip
        return true if requirement.blank? || requirement == "*" || requirement.downcase == "latest"
        return true if non_registry_dependency_requirement?(requirement)

        minimum_version = Gem::Version.new(minimum)
        requirement.split("||").any? do |range|
          floor = dependency_requirement_floor(range)
          floor && Gem::Version.new(floor) >= minimum_version
        end
      end

      def dependency_requirement_floor(range)
        range
          .split(/[,\s]+/)
          .filter_map { |token| dependency_requirement_token_version(token) }
          .first
      end

      def dependency_requirement_token_version(token)
        return nil if token.blank? || token.start_with?("<")

        match = token.match(/\A(?:>=|>|=|~>|\^|~)?v?(\d+)(?:\.(\d+|x|\*))?(?:\.(\d+|x|\*))?(?:[-+][0-9A-Za-z.-]+)?\z/i)
        return nil unless match

        [match[1], match[2], match[3]]
          .map { |part| part.presence&.then { |value| %w[x *].include?(value.downcase) ? "0" : value } || "0" }
          .join(".")
      end

      def non_registry_dependency_requirement?(requirement)
        requirement.match?(/\A(?:file|link|workspace|git|github|http|https|npm):/) ||
          requirement.match?(/\Agit\+/)
      end

      def missing_vite_frontend_dependencies
        installed = package_json_dependencies
        VITE_FRONTEND_DEPENDENCIES.reject { |package_name| installed.key?(package_name) }
      end

      def package_json_dependencies
        return {} unless package_json_file?

        package_json = parsed_package_json
        %w[dependencies devDependencies peerDependencies optionalDependencies]
          .each_with_object({}) do |section, dependencies|
            dependencies.merge!(package_json.fetch(section, {}))
          end
      rescue JSON::ParserError
        {}
      end

      def package_json_scripts
        scripts = parsed_package_json.fetch("scripts", {})
        scripts.is_a?(Hash) ? scripts : {}
      rescue JSON::ParserError
        {}
      end

      def parsed_package_json
        @package_json ||= begin
          package_json_file? ? JSON.parse(File.read(package_json_path)) : {}
        end
      rescue JSON::ParserError
        {}
      end

      def package_json_file?
        File.exist?(package_json_path)
      end

      def package_json_path
        File.join(destination_root, "package.json")
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

      def tailwind_cli_package?
        package_json_dependencies.key?(TAILWIND_CLI_PACKAGE_NAME)
      end

      def tailwind_cli_supported?
        requirement = package_json_dependencies[TAILWIND_CLI_PACKAGE_NAME]
        requirement.present? && dependency_requirement_satisfies_minimum?(requirement, TAILWIND_MINIMUM_VERSION)
      end

      def tailwind_package_script?
        package_json_scripts.any? do |_name, command|
          command = command.to_s
          command.include?("tailwindcss") && command.include?(admin_stylesheet_path)
        end
      end

      def tailwind_build_script_name
        "build:#{namespace_name}:css"
      end

      def tailwind_build_command
        "tailwindcss -i #{admin_stylesheet_path} -o app/assets/builds/#{namespace_name}.css --minify"
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
