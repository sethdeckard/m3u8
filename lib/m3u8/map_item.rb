# frozen_string_literal: true

module M3u8
  # MapItem represents a EXT-X-MAP tag which specifies how to obtain the Media
  # Initialization Section
  class MapItem
    extend M3u8
    include M3u8
    include AttributeFormatter

    attr_accessor :uri, :byterange

    def initialize(params = {})
      initialize_with_byterange(params)
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      range_value = attributes['BYTERANGE']
      range = ByteRange.parse(range_value) unless range_value.nil?
      options = { uri: attributes['URI'], byterange: range }
      MapItem.new(options)
    end

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
