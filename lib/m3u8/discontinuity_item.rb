# frozen_string_literal: true

module M3u8
  # DiscontinuityItem represents a EXT-X-DISCONTINUITY tag to indicate a
  # discontinuity between the SegmentItems that proceed and follow it.
  class DiscontinuityItem
    def to_s
      "#EXT-X-DISCONTINUITY\n"
    end
  end
end
