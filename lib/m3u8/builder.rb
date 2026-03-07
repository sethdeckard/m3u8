# frozen_string_literal: true

module M3u8
  # Builder provides a block-based DSL for constructing playlists
  class Builder
    ITEMS = {
      segment: 'SegmentItem',
      playlist: 'PlaylistItem',
      media: 'MediaItem',
      session_data: 'SessionDataItem',
      session_key: 'SessionKeyItem',
      content_steering: 'ContentSteeringItem',
      key: 'KeyItem',
      map: 'MapItem',
      date_range: 'DateRangeItem',
      time: 'TimeItem',
      bitrate: 'BitrateItem',
      part: 'PartItem',
      preload_hint: 'PreloadHintItem',
      rendition_report: 'RenditionReportItem',
      skip: 'SkipItem',
      define: 'DefineItem',
      playback_start: 'PlaybackStart'
    }.freeze

    ZERO_ARG_ITEMS = {
      discontinuity: 'DiscontinuityItem',
      gap: 'GapItem'
    }.freeze

    # @param playlist [Playlist] playlist to build into
    def initialize(playlist)
      @playlist = playlist
    end

    ITEMS.each do |method_name, class_name|
      define_method(method_name) do |params = {}|
        @playlist.items << M3u8.const_get(class_name).new(params)
      end
    end

    ZERO_ARG_ITEMS.each do |method_name, class_name|
      define_method(method_name) do
        @playlist.items << M3u8.const_get(class_name).new
      end
    end
  end
end
