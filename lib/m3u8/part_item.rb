# frozen_string_literal: true

module M3u8
  # PartItem represents an EXT-X-PART tag for Low-Latency HLS partial
  # segments.
  class PartItem
    extend M3u8
    include M3u8
    include AttributeFormatter

    # @return [String, nil] partial segment URI
    # @return [Float, nil] partial segment duration
    # @return [Boolean, nil] whether segment is independent
    # @return [ByteRange, nil] byte range
    # @return [Boolean, nil] whether segment is a gap
    attr_accessor :uri, :duration, :independent, :byterange, :gap

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      initialize_with_byterange(params)
    end

    # Parse an EXT-X-PART tag.
    # @param text [String] raw tag line
    # @return [PartItem]
    def self.parse(text)
      attributes = parse_attributes(text)
      range_value = attributes['BYTERANGE']
      range = ByteRange.parse(range_value) unless range_value.nil?
      PartItem.new(
        uri: attributes['URI'],
        duration: attributes['DURATION'].to_f,
        independent: parse_yes_no(attributes['INDEPENDENT']),
        byterange: range,
        gap: parse_yes_no(attributes['GAP'])
      )
    end

    # Render as an m3u8 EXT-X-PART tag.
    # @return [String]
    def to_s
      "#EXT-X-PART:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      [unquoted_format('DURATION', duration),
       quoted_format('URI', uri),
       independent_format,
       quoted_format('BYTERANGE', byterange),
       gap_format].compact.join(',')
    end

    def independent_format
      return unless independent

      'INDEPENDENT=YES'
    end

    def gap_format
      return unless gap

      'GAP=YES'
    end
  end
end
