# frozen_string_literal: true

module M3u8
  # PartInfItem represents an EXT-X-PART-INF tag which provides
  # information about partial segments in the playlist.
  class PartInfItem
    extend M3u8

    attr_accessor :part_target

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      PartInfItem.new(
        part_target: attributes['PART-TARGET'].to_f
      )
    end

    def to_s
      "#EXT-X-PART-INF:PART-TARGET=#{part_target}"
    end
  end
end
