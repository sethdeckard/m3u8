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

    def playlist(params = {})
      @playlist.items << PlaylistItem.new(params)
    end

    def media(params = {})
      @playlist.items << MediaItem.new(params)
    end

    def session_data(params = {})
      @playlist.items << SessionDataItem.new(params)
    end

    def session_key(params = {})
      @playlist.items << SessionKeyItem.new(params)
    end

    def content_steering(params = {})
      @playlist.items << ContentSteeringItem.new(params)
    end
  end
end
