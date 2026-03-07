# frozen_string_literal: true

module M3u8
  # KeyItem represents a set of EXT-X-KEY attributes
  class KeyItem
    include Encryptable
    extend M3u8

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      options = convert_key_names(params)
      options.merge(params).each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-KEY tag.
    # @param text [String] raw tag line
    # @return [KeyItem]
    def self.parse(text)
      attributes = parse_attributes(text)
      KeyItem.new(attributes)
    end

    # Render as an m3u8 EXT-X-KEY tag.
    # @return [String]
    def to_s
      "#EXT-X-KEY:#{attributes_to_s}"
    end
  end
end
