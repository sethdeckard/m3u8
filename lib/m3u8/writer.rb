module M3u8
  class Writer
    attr_accessor :io

    def initialize(io)
      self.io = io
    end

    def write(playlist)
      validate playlist

      io.puts '#EXTM3U'
      write_header(playlist) unless playlist.master?

      playlist.items.each do |item|
        io.puts item.to_s
      end

      return if playlist.master?
      io.puts '#EXT-X-ENDLIST'
    end

    private

    def validate(playlist)
      return if playlist.valid?
      fail PlaylistTypeError, 'Playlist is invalid.'
    end

    def write_header(playlist)
      io.puts "#EXT-X-PLAYLIST-TYPE:#{playlist.type}" unless playlist.type.nil?
      io.puts "#EXT-X-VERSION:#{playlist.version}"
      io.puts '#EXT-X-I-FRAMES-ONLY' if playlist.iframes_only
      io.puts "#EXT-X-MEDIA-SEQUENCE:#{playlist.sequence}"
      io.puts "#EXT-X-ALLOW-CACHE:#{cache(playlist)}"
      io.puts "#EXT-X-TARGETDURATION:#{playlist.target}"
    end

    def cache(playlist)
      playlist.cache ? 'YES' : 'NO'
    end
  end
end
