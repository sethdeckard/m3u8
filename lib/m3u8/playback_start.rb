# frozen_string_literal: true

module M3u8
  # PlaybackStart represents a #EXT-X-START tag and attributes
  class PlaybackStart
    extend M3u8
    include AttributeFormatter

    # @return [Float, nil] time offset in seconds
    # @return [Boolean, nil] whether start is precise
    attr_accessor :time_offset, :precise

    # @param options [Hash] attribute key-value pairs
    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-START tag.
    # @param text [String] raw tag line
    # @return [PlaybackStart]
    def self.parse(text)
      attributes = parse_attributes(text)
      precise = attributes['PRECISE']
      options = {
        time_offset: attributes['TIME-OFFSET'].to_f,
        precise: precise.nil? ? nil : parse_yes_no(precise)
      }
      PlaybackStart.new(options)
    end

    # Render as an m3u8 EXT-X-START tag.
    # @return [String]
    def to_s
      attributes = ["TIME-OFFSET=#{time_offset}",
                    boolean_format('PRECISE', precise)].compact.join(',')
      "#EXT-X-START:#{attributes}"
    end
  end
end
