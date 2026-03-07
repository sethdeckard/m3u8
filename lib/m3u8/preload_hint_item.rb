# frozen_string_literal: true

module M3u8
  # PreloadHintItem represents an EXT-X-PRELOAD-HINT tag which allows
  # a server to indicate a resource that will be needed soon.
  class PreloadHintItem
    extend M3u8
    include AttributeFormatter

    # @return [String, nil] hint type (PART or MAP)
    # @return [String, nil] hint resource URI
    # @return [Integer, nil] byte range start offset
    # @return [Integer, nil] byte range length
    attr_accessor :type, :uri, :byterange_start, :byterange_length

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-PRELOAD-HINT tag.
    # @param text [String] raw tag line
    # @return [PreloadHintItem]
    def self.parse(text)
      attributes = parse_attributes(text)
      PreloadHintItem.new(
        type: attributes['TYPE'],
        uri: attributes['URI'],
        byterange_start:
          parse_int(attributes['BYTERANGE-START']),
        byterange_length:
          parse_int(attributes['BYTERANGE-LENGTH'])
      )
    end

    # Render as an m3u8 EXT-X-PRELOAD-HINT tag.
    # @return [String]
    def to_s
      "#EXT-X-PRELOAD-HINT:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      [unquoted_format('TYPE', type),
       quoted_format('URI', uri),
       unquoted_format('BYTERANGE-START', byterange_start),
       unquoted_format('BYTERANGE-LENGTH',
                       byterange_length)].compact.join(',')
    end
  end
end
