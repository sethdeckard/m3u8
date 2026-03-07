# frozen_string_literal: true

module M3u8
  # PartInfItem represents an EXT-X-PART-INF tag which provides
  # information about partial segments in the playlist.
  class PartInfItem
    extend M3u8

    # @return [Float, nil] partial segment target duration
    attr_accessor :part_target

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-PART-INF tag.
    # @param text [String] raw tag line
    # @return [PartInfItem]
    def self.parse(text)
      attributes = parse_attributes(text)
      PartInfItem.new(
        part_target: attributes['PART-TARGET'].to_f
      )
    end

    # Render as an m3u8 EXT-X-PART-INF tag.
    # @return [String]
    def to_s
      "#EXT-X-PART-INF:PART-TARGET=#{part_target}"
    end
  end
end
