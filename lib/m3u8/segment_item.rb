module M3u8
  # SegmentItem represents EXTINF attributes with the URI that follows,
  # optionally allowing an EXT-X-BYTERANGE tag to be set.
  class SegmentItem
    attr_accessor :duration, :segment, :comment, :byterange

    def initialize(params = {})
      params.each do |key, value|
        value = ByteRange.new(value) if value.is_a?(Hash)
        instance_variable_set("@#{key}", value)
      end
    end

    def to_s
      "#EXTINF:#{duration},#{comment}#{byterange_format}\n#{segment}"
    end

    private

    def byterange_format
      return if byterange.nil?
      "\n#EXT-X-BYTERANGE:#{byterange}"
    end
  end
end
