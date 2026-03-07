# frozen_string_literal: true

module M3u8
  # DiscontinuityItem represents a EXT-X-DISCONTINUITY tag to indicate a
  # discontinuity between the SegmentItems that proceed and follow it.
  class DiscontinuityItem
    # Render as an m3u8 EXT-X-DISCONTINUITY tag.
    # @return [String]
    def to_s
      "#EXT-X-DISCONTINUITY\n"
    end
  end
end
