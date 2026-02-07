# frozen_string_literal: true

module M3u8
  # GapItem represents an EXT-X-GAP tag to indicate that the segment URI
  # to which it applies does not contain media data and should not be
  # loaded by clients.
  class GapItem
    def to_s
      '#EXT-X-GAP'
    end
  end
end
