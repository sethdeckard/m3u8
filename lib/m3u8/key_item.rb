module M3u8
  # KeyItem represents a set of EXT-X-KEY attributes
  class KeyItem
    extend M3u8
    include Encryptable

    def initialize(params = {})
      options = convert_key_names(params)
      options.merge(params).each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      KeyItem.new(attributes)
    end

    def to_s
      "#EXT-X-KEY:#{attributes_to_s}"
    end
  end
end
