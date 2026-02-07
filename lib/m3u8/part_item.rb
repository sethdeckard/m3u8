# frozen_string_literal: true

module M3u8
  # PartItem represents an EXT-X-PART tag for Low-Latency HLS partial
  # segments.
  class PartItem
    extend M3u8
    include M3u8

    attr_accessor :uri, :duration, :independent, :byterange, :gap

    def initialize(params = {})
      intialize_with_byterange(params)
    end

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

    def to_s
      "#EXT-X-PART:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      [duration_format,
       uri_format,
       independent_format,
       byterange_format,
       gap_format].compact.join(',')
    end

    def duration_format
      "DURATION=#{duration}"
    end

    def uri_format
      %(URI="#{uri}")
    end

    def independent_format
      return unless independent

      'INDEPENDENT=YES'
    end

    def byterange_format
      return if byterange.nil?

      %(BYTERANGE="#{byterange}")
    end

    def gap_format
      return unless gap

      'GAP=YES'
    end
  end
end
