module M3u8
  # DiscontinuityItem represents a EXT-X-DISCONTINUITY tag to indicate a
  # discontinuity between the SegmentItems that proceed and follow it.
  class DiscontinuityItem
    attr_accessor :tag

    def to_s
      "#EXT-X-DISCONTINUITY\n"
    end
  end
end
