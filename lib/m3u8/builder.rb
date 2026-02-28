# frozen_string_literal: true

module M3u8
  # Builder provides a block-based DSL for constructing playlists
  class Builder
    def initialize(playlist)
      @playlist = playlist
    end

    def segment(params = {})
      @playlist.items << SegmentItem.new(params)
    end
  end
end
