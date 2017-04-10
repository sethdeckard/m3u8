# frozen_string_literal: true
module M3u8
  # Writer provides generation of text output of playlists in m3u8 format
  class Writer
    attr_accessor :io

    def initialize(io)
      @io = io
    end

    def write(playlist)
      validate(playlist)
      write_header(playlist)

      playlist.items.each do |item|
        io.puts item.to_s
      end

      write_footer(playlist)
    end

    def write_footer(playlist)
      return if playlist.live? || playlist.master?
      io.puts '#EXT-X-ENDLIST'
    end

    def write_header(playlist)
      io.puts '#EXTM3U'
      if playlist.master?
        write_master_playlist_header(playlist)
      else
        write_media_playlist_header(playlist)
      end
    end

    private

    def target_duration_format(playlist)
      format('#EXT-X-TARGETDURATION:%d', playlist.target)
    end

    def validate(playlist)
      return if playlist.valid?
      raise PlaylistTypeError, 'Playlist is invalid.'
    end

    def write_cache_tag(cache)
      return if cache.nil?

      io.puts "#EXT-X-ALLOW-CACHE:#{cache ? 'YES' : 'NO'}"
    end

    def write_discontinuity_sequence_tag(sequence)
      return if sequence.nil?

      io.puts "#EXT-X-DISCONTINUITY-SEQUENCE:#{sequence}"
    end

    def write_independent_segments_tag(independent_segments)
      return unless independent_segments

      io.puts '#EXT-X-INDEPENDENT-SEGMENTS'
    end

    def write_master_playlist_header(playlist)
      write_version_tag(playlist.version)
      write_independent_segments_tag(playlist.independent_segments)
    end

    def write_media_playlist_header(playlist)
      io.puts "#EXT-X-PLAYLIST-TYPE:#{playlist.type}" unless playlist.type.nil?
      write_version_tag(playlist.version)
      write_independent_segments_tag(playlist.independent_segments)
      io.puts '#EXT-X-I-FRAMES-ONLY' if playlist.iframes_only
      io.puts "#EXT-X-MEDIA-SEQUENCE:#{playlist.sequence}"
      write_discontinuity_sequence_tag(playlist.discontinuity_sequence)
      write_cache_tag(playlist.cache)
      io.puts target_duration_format(playlist)
    end

    def write_version_tag(version)
      return if version.nil?

      io.puts "#EXT-X-VERSION:#{version}"
    end
  end
end
