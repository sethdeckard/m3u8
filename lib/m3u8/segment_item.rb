# frozen_string_literal: true

module M3u8
  # SegmentItem represents EXTINF attributes with the URI that follows,
  # optionally allowing an EXT-X-BYTERANGE tag to be set.
  class SegmentItem
    include M3u8
    include AttributeFormatter

    # @return [Float, nil] segment duration in seconds
    # @return [String, nil] segment URI
    # @return [String, nil] human-readable comment after duration
    # @return [TimeItem, Time, nil] program date-time
    # @return [ByteRange, nil] byte range
    attr_accessor :duration, :segment, :comment, :program_date_time, :byterange

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      initialize_with_byterange(params)
    end

    # Parse an EXTINF tag line.
    # @param text [String] raw tag line
    # @return [SegmentItem]
    def self.parse(text)
      values = text.gsub('#EXTINF:', '')
                   .tr("\n", ',').split(',')
      options = { duration: values[0].to_f }
      options[:comment] = values[1] unless values[1].nil?
      SegmentItem.new(options)
    end

    # Render as an m3u8 EXTINF tag with segment URI.
    # @return [String]
    def to_s
      "#EXTINF:#{decimal_format(duration)},#{comment}#{byterange_format}" \
        "\n#{date_format}#{segment}"
    end

    def date_format
      return if program_date_time.nil?

      pdt = if program_date_time.is_a?(TimeItem)
              program_date_time
            else
              TimeItem.new(time: program_date_time)
            end
      "#{pdt}\n"
    end

    private

    def byterange_format
      return if byterange.nil?

      "\n#EXT-X-BYTERANGE:#{byterange}"
    end
  end
end
