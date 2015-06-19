module M3u8
  # MapItem represents a EXT-X-MAP tag which specifies how to obtain the Media
  # Initialization Section
  class MapItem
    include M3u8
    attr_accessor :uri, :byterange

    def initialize(params = {})
      params.each do |key, value|
        value = ByteRange.new(value) if value.is_a?(Hash)
        instance_variable_set("@#{key}", value)
      end
    end

    def parse(text)
      attributes = parse_attributes text
      range_value = attributes['BYTERANGE']
      unless range_value.nil?
        range = ByteRange.new
        range.parse range_value
      end
      options = { uri: attributes['URI'], byterange: range }
      initialize options
    end

    def to_s
      %(#EXT-X-MAP:URI="#{uri}"#{byterange_format})
    end

    private

    def byterange_format
      return if byterange.nil?
      %(,BYTERANGE="#{byterange}")
    end
  end
end
