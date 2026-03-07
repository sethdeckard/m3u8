# frozen_string_literal: true

module M3u8
  # PlaybackStart represents a #EXT-X-START tag and attributes
  class PlaybackStart
    extend M3u8
    include AttributeFormatter

    attr_accessor :time_offset, :precise

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      precise = attributes['PRECISE']
      options = {
        time_offset: attributes['TIME-OFFSET'].to_f,
        precise: precise.nil? ? nil : parse_yes_no(precise)
      }
      PlaybackStart.new(options)
    end

    def to_s
      attributes = ["TIME-OFFSET=#{time_offset}",
                    boolean_format('PRECISE', precise)].compact.join(',')
      "#EXT-X-START:#{attributes}"
    end
  end
end
