module M3u8
  # KeyItem represents a set of EXT-X-SESSION-KEY attributes
  class SessionKeyItem
    extend M3u8
    include Encryptable

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      SessionKeyItem.new(Encryptable.convert_key_names(attributes))
    end

    def to_s
      "#EXT-X-SESSION-KEY:#{attributes_to_s}"
    end
  end
end
