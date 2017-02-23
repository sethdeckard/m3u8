# frozen_string_literal: true
module M3u8
  # PlaybackStart represents a #EXT-X-START tag and attributes
  class PlaybackStart
    include M3u8
    attr_accessor :time_offset, :precise

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def parse(text)
      attributes = parse_attributes(text)
      @time_offset = attributes['TIME-OFFSET'].to_f
      precise = attributes['PRECISE']
      @precise = parse_yes_no(precise) unless precise.nil?
    end

    def to_s
      attributes = ["TIME-OFFSET=#{time_offset}",
                    precise_format].compact.join(',')
      "#EXT-X-START:#{attributes}"
    end

    private

    def precise_format
      return if precise.nil?
      "PRECISE=#{to_yes_no(precise)}"
    end
  end
end
