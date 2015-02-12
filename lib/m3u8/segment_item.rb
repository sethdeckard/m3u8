module M3u8
  # SegmentItem represents EXTINF attributes with the URI that follows,
  # optionally allowing an EXT-X-BYTERANGE tag to be set.
  class SegmentItem
    attr_accessor :duration, :segment, :comment, :byterange_length,
                  :byterange_start

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def to_s
      "#EXTINF:#{duration},#{comment}#{byterange_format}\n#{segment}"
    end

    private

    def byterange_format
      return if byterange_length.nil?
      "\n#EXT-X-BYTERANGE:#{byterange_length}#{byterange_start_format}"
    end

    def byterange_start_format
      return if byterange_start.nil?
      "@#{byterange_start}"
    end
  end
end
