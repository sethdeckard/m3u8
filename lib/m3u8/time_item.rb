# frozen_string_literal: true

module M3u8
  # TimeItem represents EXT-X-PROGRAM-DATE-TIME
  class TimeItem
    extend M3u8

    # @return [Time, String, nil] program date-time value
    attr_accessor :time

    # @param params [Hash] :time value
    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-PROGRAM-DATE-TIME tag.
    # @param text [String] raw tag line
    # @return [TimeItem]
    def self.parse(text)
      time = text.gsub('#EXT-X-PROGRAM-DATE-TIME:', '')
      options = { time: Time.parse(time) }
      TimeItem.new(options)
    end

    # Render as an m3u8 EXT-X-PROGRAM-DATE-TIME tag.
    # @return [String]
    def to_s
      %(#EXT-X-PROGRAM-DATE-TIME:#{time_format})
    end

    private

    def time_format
      return time if time.is_a?(String)

      time.iso8601
    end
  end
end
