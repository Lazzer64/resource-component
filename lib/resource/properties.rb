class Resource
  class Properties < ::Hash
    def initialize(resource_class, hash)
      @resource_class = resource_class
      merge!(convert_to_symbol_form(hash))
    end

    def valid?(tag)
      req_properties(tag).find { |key| !has_key?(key) }.nil?
    end

    private

    def metadata
      @resource_class::METADATA
    end

    def req_properties(tag)
      metadata.keys.select { |key| metadata[key].include?(tag) }
    end

    def convert_to_symbol_form(obj)
      if obj.is_a?(Array)
        obj.map { |el| convert_to_symbol_form(el) }
      elsif obj.is_a?(Hash)
        obj.inject({}) do |h, (k, v)|
          h.merge(k.to_sym => convert_to_symbol_form(v))
        end
      else
        obj
      end
    end
  end
end
