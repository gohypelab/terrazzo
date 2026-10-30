module Terrazzo
  module Field
    class Associative < Base
      OPTION_LIMIT = 10

      def association_options(search:)
        scope = candidate_scope
        columns = options[:searchable_fields] || (%w[name title email slug code original_filename id] &
          (associated_class.column_names + associated_class.stored_attributes.values.flatten.map(&:to_s)))
        scope = Terrazzo::Search.new(scope, nil, search).run_for_columns(columns)
        scope = scope.reorder(options[:order] || association_primary_key).order(association_primary_key)
        records = scope.limit(OPTION_LIMIT).to_a
        {
          resourceOptions: records.map { |record| option_for(record) }
        }
      end

      def selected_resource_options
        records = data.nil? ? [] : (data.respond_to?(:to_ary) ? data.to_ary : [data])
        records.map { |record| option_for(record) }
      end

      def candidate_scope
        scope = if options[:scope].is_a?(Proc)
          options[:scope].call(associated_class)
        elsif options[:scope]
          associated_class.public_send(options[:scope])
        else
          associated_class.all
        end
        options.key?(:includes) ? scope.includes(*options[:includes]) : scope
      end

      def option_for(record)
        [display_name(record), record.public_send(association_primary_key).to_s]
      end

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
        dashboard = dashboard_for(record.class)
        return dashboard.display_resource(record) if dashboard && custom_display_resource?(dashboard)

        fallback_display_name(record)
      end

      def fallback_display_name(record)
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
        scope.map { |r| [display_name(r), r.public_send(pk).to_s] }
      end

      def dashboard_for(klass)
        return nil unless klass

        "#{klass.name}Dashboard".constantize.new
      rescue NameError
        nil
      end

      def custom_display_resource?(dashboard)
        dashboard.method(:display_resource).owner != Terrazzo::BaseDashboard
      end

      def association_primary_key
        reflection = resource&.class&.reflect_on_association(attribute)
        reflection&.association_primary_key || :id
      end
    end
  end
end
