module Terrazzo
  module HasManyPagination
    PARAM_SUFFIX = "_page".freeze

    module_function

    def extract(params, attributes)
      attributes.each_with_object({}) do |attr, result|
        value = params[param_key(attr)] || params[param_key(attr).to_sym]
        next if value.nil?
        result[attr.to_sym] = { _page: value.to_i }
      end
    end

    def param_key(attribute)
      "#{attribute}#{PARAM_SUFFIX}"
    end
  end
end
