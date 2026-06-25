module Terrazzo
  module Generators
    module Views
      module GeneratedDefaultsHelper
        PAGE_COMPONENTS = {
          "index" => "AdminIndex",
          "show" => "AdminShow",
          "new" => "AdminNew",
          "edit" => "AdminEdit",
        }.freeze

        private

        def copy_file_over_generated(source, destination, generated_content:)
          options = generated_file?(destination, generated_content) ? { force: true } : {}

          copy_file source, destination, **options
        end

        def copy_file_unless_exists(source, destination)
          if File.exist?(File.join(destination_root, destination))
            say_status :skip, destination, :yellow
            return
          end

          copy_file source, destination
        end

        def copy_resource_page_file(source, destination)
          before = read_destination(destination)
          generated_before = before == read_template(source)

          copy_file source, destination
          after = read_destination(destination)
          rewrite_resource_page_imports(destination) if after && (before.nil? || after != before || generated_before)
        end

        def copy_resource_page_file_unless_exists(source, destination)
          if File.exist?(File.join(destination_root, destination))
            rewrite_resource_page_imports(destination) if read_destination(destination) == read_template(source)
            say_status :skip, destination, :yellow
            return
          end

          copy_file source, destination
          rewrite_resource_page_imports(destination)
        end

        def generated_file?(destination, generated_content)
          path = File.join(destination_root, destination)
          File.exist?(path) && File.read(path) == generated_content
        end

        def generated_page_stub(name)
          component = PAGE_COMPONENTS.fetch(name)

          %(export { #{component} as default } from "terrazzo/pages";\n)
        end

        def generated_navigation_partial
          <<~RUBY
            resources = Terrazzo::Namespace.new(namespace).navigation_resources
            navigation_groups = resources.group_by(&:navigation_group).map do |label, items|
              { label: label, items: items }
            end

            json.array! navigation_groups do |group|
              json.label group[:label]
              json.items do
                json.array! group[:items] do |r|
                  json.label r.navigation_label
                  json.path url_for(controller: "/\#{r.controller_path}", action: :index, only_path: true)
                  json.active r.controller_path == controller_path
                end
              end
            end
          RUBY
        end

        def rewrite_resource_page_imports(destination)
          path = File.join(destination_root, destination)
          source = File.read(path)
          prefix = page_barrel_import_prefix(destination)
          rewritten = source.gsub(/from "\.\.\/(fields|components(?:\/ui)?)"/) do
            %(from "#{prefix}#{Regexp.last_match(1)}")
          end

          File.write(path, rewritten) if rewritten != source
        end

        def read_destination(destination)
          path = File.join(destination_root, destination)
          File.read(path) if File.exist?(path)
        end

        def read_template(source)
          File.read(File.join(self.class.source_root, source))
        end

        def page_barrel_import_prefix(destination)
          relative_path = destination.delete_prefix("app/views/#{namespace_name}/")
          directory = File.dirname(relative_path)
          depth = directory.split("/").reject(&:empty?).length

          "../" * depth
        end
      end
    end
  end
end
