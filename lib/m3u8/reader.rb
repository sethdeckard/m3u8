module M3u8
  # Reader provides parsing of m3u8 playlists
  class Reader
    include M3u8
    attr_accessor :playlist, :item, :open, :master, :tags

    def initialize(*)
      @tags = [basic_tags,
               media_segment_tags,
               media_playlist_tags,
               master_playlist_tags].inject(:merge)
    end

    def read(input)
      self.playlist = Playlist.new
      input.each_line do |line|
        parse_line line
      end
      playlist
    end

    private

    def basic_tags
      { '#EXT-X-VERSION' => proc { |line| parse_version line } }
    end

    def media_segment_tags
      { '#EXTINF' => proc { |line| parse_segment line },
        '#EXT-X-DISCONTINUITY' => proc { |line| parse_discontinuity line },
        '#EXT-X-BYTERANGE' => proc { |line| parse_byterange line },
        '#EXT-X-KEY' => proc { |line| parse_key line }
      }
    end

    def media_playlist_tags
      { '#EXT-X-MEDIA-SEQUENCE' => proc { |line| parse_sequence line },
        '#EXT-X-ALLOW-CACHE' => proc { |line| parse_cache line },
        '#EXT-X-TARGETDURATION' => proc { |line| parse_target line },
        '#EXT-X-I-FRAMES-ONLY' => proc { playlist.iframes_only = true },
        '#EXT-X-PLAYLIST-TYPE' => proc { |line| parse_playlist_type line }
      }
    end

    def master_playlist_tags
      { '#EXT-X-MEDIA' => proc { |line| parse_media line },
        '#EXT-X-SESSION-DATA' => proc { |line| parse_session_data line },
        '#EXT-X-STREAM-INF' => proc { |line| parse_stream line },
        '#EXT-X-I-FRAME-STREAM-INF' => proc { |line| parse_iframe_stream line }
      }
    end

    def parse_line(line)
      return if match_tag(line)
      parse_next_line line if !item.nil? && open
    end

    def match_tag(line)
      tag = @tags.select { |key| line.start_with? key }
      return unless tag.values.first
      tag.values.first.call line
      true
    end

    def parse_playlist_type(line)
      playlist.type = line.gsub('#EXT-X-PLAYLIST-TYPE:', '').delete!("\n")
    end

    def parse_version(line)
      playlist.version = line.gsub('#EXT-X-VERSION:', '').to_i
    end

    def parse_sequence(line)
      playlist.sequence = line.gsub('#EXT-X-MEDIA-SEQUENCE:', '').to_i
    end

    def parse_cache(line)
      line = line.gsub('#EXT-X-ALLOW-CACHE:', '')
      playlist.cache = parse_yes_no(line)
    end

    def parse_target(line)
      playlist.target = line.gsub('#EXT-X-TARGETDURATION:', '').to_i
    end

    def parse_stream(line)
      self.master = true
      self.open = true

      self.item = M3u8::PlaylistItem.new
      item.parse line
    end

    def parse_iframe_stream(line)
      self.master = true
      self.open = false

      self.item = M3u8::PlaylistItem.new
      item.parse line
      item.iframe = true
      playlist.items.push item
    end

    def parse_discontinuity(*)
      self.master = false
      self.open = false

      self.item = M3u8::DiscontinuityItem.new
      playlist.items.push item
    end

    def parse_key(line)
      item = M3u8::KeyItem.parse line
      playlist.items.push item
    end

    def parse_segment(line)
      self.item = M3u8::SegmentItem.new
      values = line.gsub('#EXTINF:', '').gsub("\n", ',').split(',')
      item.duration = values[0].to_f
      item.comment = values[1] unless values[1].nil?

      self.master = false
      self.open = true
    end

    def parse_byterange(line)
      values = line.gsub('#EXT-X-BYTERANGE:', '').gsub("\n", ',').split '@'
      item.byterange_length = values[0].to_i
      item.byterange_start = values[1].to_i unless values[1].nil?
    end

    def parse_session_data(line)
      item = M3u8::SessionDataItem.parse line
      playlist.items.push item
    end

    def parse_media(line)
      self.open = false
      self.item = M3u8::MediaItem.new
      item.parse line
      playlist.items.push item
    end

    def parse_next_line(line)
      value = line.gsub "\n", ''
      if master
        item.uri = value
      else
        item.segment = value
      end
      playlist.items.push item
      self.open = false
    end
  end
end
