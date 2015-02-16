module M3u8
  class SegmentTagDiscontinuity
    attr_accessor :tag

    def initialize
    end

    def to_s
      "#EXT-X-DISCONTINUITY\n"
    end
  end
end
