module Terrazzo
  module Field
    class Asset < Base
      def serialize_value(mode)
        return nil if data.nil? || !data.attached?

        case mode
        when :index
          data.filename.to_s
        when :show
          { filename: data.filename.to_s, byteSize: data.byte_size, contentType: data.content_type }
        when :form
          { filename: data.filename.to_s, signedId: data.signed_id }
        else
          data.filename.to_s
        end
      end

      class << self
        def searchable?
          false
        end

        def sortable?
          false
        end

        def eager_load?
          true
        end
      end
    end
  end
end
