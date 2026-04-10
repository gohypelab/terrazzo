module Terrazzo
  module HasManyPagination
    PARAM_PREFIX = "hm_".freeze
    PARAM_SUFFIX = "_page".freeze

    module_function

    def extract(params)
      result = {}
      params.each do |key, value|
        key_s = key.to_s
        next unless key_s.start_with?(PARAM_PREFIX) && key_s.end_with?(PARAM_SUFFIX)
        attr = key_s[PARAM_PREFIX.length...-PARAM_SUFFIX.length]
        next if attr.empty?
        result[attr.to_sym] = { _page: value.to_i }
      end
      result
    end

    def param_key(attribute)
      "#{PARAM_PREFIX}#{attribute}#{PARAM_SUFFIX}"
    end
  end
end
