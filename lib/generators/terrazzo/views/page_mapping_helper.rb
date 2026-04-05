module Terrazzo
  module Generators
    module Views
      module PageMappingHelper
        private

        def register_page_mapping(action)
          mapping_path = File.join(destination_root, "app/javascript/#{namespace_name}/page_to_page_mapping.js")
          return unless File.exist?(mapping_path)

          component_name = "#{resource.gsub('::', '')}#{action.capitalize}"
          import_path = "../../views/#{namespace_name}/#{resource_path}/#{action}"
          key = "'#{namespace_name}/#{resource_path}/#{action}'"

          content = File.read(mapping_path)
          return if content.include?(key)

          # Add import before the pages object declaration
          import_line = "import #{component_name} from \"#{import_path}\";\n"
          inject_into_file mapping_path, import_line, before: "\nconst pages"

          # Add mapping entry inside the pages object (before its closing brace)
          entry_line = "  #{key}: #{component_name},\n"
          inject_into_file mapping_path, entry_line, before: "}\n\n//"
        end
      end
    end
  end
end
