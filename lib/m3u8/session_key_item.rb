# frozen_string_literal: true
module M3u8
  # KeyItem represents a set of EXT-X-SESSION-KEY attributes
  class SessionKeyItem
    include Encryptable
    extend M3u8

    def initialize(params = {})
      options = convert_key_names(params)
      options.merge(params).each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      SessionKeyItem.new(attributes)
    end

    def to_s
      "#EXT-X-SESSION-KEY:#{attributes_to_s}"
    end
  end
end
