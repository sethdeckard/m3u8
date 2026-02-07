# frozen_string_literal: true

module M3u8
  # SegmentItem represents EXTINF attributes with the URI that follows,
  # optionally allowing an EXT-X-BYTERANGE tag to be set.
  class SegmentItem
    include M3u8

    attr_accessor :duration, :segment, :comment, :program_date_time, :byterange

    def initialize(params = {})
      intialize_with_byterange(params)
    end

    def to_s
      "#EXTINF:#{duration},#{comment}#{byterange_format}" \
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
