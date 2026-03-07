# frozen_string_literal: true

module M3u8
  # MapItem represents a EXT-X-MAP tag which specifies how to obtain the Media
  # Initialization Section
  class MapItem
    extend M3u8
    include M3u8
    include AttributeFormatter

    # @return [String, nil] URI of the initialization section
    # @return [ByteRange, nil] byte range within the resource
    attr_accessor :uri, :byterange

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      initialize_with_byterange(params)
    end

    # Parse an EXT-X-MAP tag.
    # @param text [String] raw tag line
    # @return [MapItem]
    def self.parse(text)
      attributes = parse_attributes(text)
      range_value = attributes['BYTERANGE']
      range = ByteRange.parse(range_value) unless range_value.nil?
      options = { uri: attributes['URI'], byterange: range }
      MapItem.new(options)
    end

    # Render as an m3u8 EXT-X-MAP tag.
    # @return [String]
    def to_s
      "#EXT-X-MAP:#{formatted_attributes.compact.join(',')}"
    end

    private

    def formatted_attributes
      [%(URI="#{uri}"),
       quoted_format('BYTERANGE', byterange)]
    end
  end
end
