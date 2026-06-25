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
      end
    end
  end
end
