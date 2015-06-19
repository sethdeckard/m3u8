module M3u8
  # MapItem represents a EXT-X-MAP tag which specifies how to obtain the Media
  # Initialization Section
  class MapItem
    attr_accessor :uri, :byterange_length, :byterange_start

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def to_s
      %(#EXT-X-MAP:URI="#{uri}"#{byterange_format})
    end

    private

    def byterange_format
      return if byterange_length.nil?
      %(,BYTERANGE:"#{byterange_length}#{byterange_start_format}")
    end

    def byterange_start_format
      return if byterange_start.nil?
      "@#{byterange_start}"
    end
  end
end
