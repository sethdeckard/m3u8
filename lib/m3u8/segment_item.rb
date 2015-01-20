module M3u8
  class SegmentItem
    attr_accessor :duration, :segment, :comment

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def to_s
      "#EXTINF:#{duration},#{comment}\n#{segment}"
    end
  end
end
