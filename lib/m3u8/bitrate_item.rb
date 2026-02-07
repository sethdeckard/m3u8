# frozen_string_literal: true

module M3u8
  # BitrateItem represents an EXT-X-BITRATE tag that indicates the
  # approximate bitrate of the following media segments in kbps.
  class BitrateItem
    attr_accessor :bitrate

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      value = text.gsub('#EXT-X-BITRATE:', '').strip
      BitrateItem.new(bitrate: value.to_i)
    end

    def to_s
      "#EXT-X-BITRATE:#{bitrate}"
    end
  end
end
