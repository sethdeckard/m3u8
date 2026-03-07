# frozen_string_literal: true

module M3u8
  # BitrateItem represents an EXT-X-BITRATE tag that indicates the
  # approximate bitrate of the following media segments in kbps.
  class BitrateItem
    # @return [Integer, nil] approximate bitrate in kbps
    attr_accessor :bitrate

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-BITRATE tag.
    # @param text [String] raw tag line
    # @return [BitrateItem]
    def self.parse(text)
      value = text.gsub('#EXT-X-BITRATE:', '').strip
      BitrateItem.new(bitrate: value.to_i)
    end

    # Render as an m3u8 EXT-X-BITRATE tag.
    # @return [String]
    def to_s
      "#EXT-X-BITRATE:#{bitrate}"
    end
  end
end
