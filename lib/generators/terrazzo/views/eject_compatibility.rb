require "generators/terrazzo/eject/eject_generator"

module Terrazzo
  module Generators
    module Views
      module EjectCompatibility
        private

        def run_eject(target)
          Terrazzo::Generators::EjectGenerator.start(
            [target, "--namespace=#{namespace_name}"],
            destination_root: destination_root,
            behavior: behavior
          )
        end
      end
    end
  end
end
