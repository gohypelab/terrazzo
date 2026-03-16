module Terrazzo
  module Field
    class Associative < Base
      class << self
        def associative?
          true
        end

        def eager_load?
          true
        end
      end

      private

      def display_name(record)
        if record.respond_to?(:display_name)
          record.display_name
        elsif record.respond_to?(:name)
          record.name
        elsif record.respond_to?(:title)
          record.title
        else
          "#{record.class.name} ##{record.id}"
        end
      end

      def associated_class
        if options[:class_name]
          options[:class_name].constantize
        else
          reflection = resource.class.reflect_on_association(attribute)
          reflection&.klass
        end
      end

      def resource_options
        return [] unless associated_class
        scope = if options[:scope].is_a?(Proc)
          options[:scope].call(associated_class)
        elsif options[:scope]
          associated_class.public_send(options[:scope])
        else
          associated_class.all
        end
        pk = association_primary_key
        scope.map { |r| [display_name(r), r.public_send(pk)] }
      end

      def association_primary_key
        reflection = resource&.class&.reflect_on_association(attribute)
        reflection&.association_primary_key || :id
      end
    end
  end
end
