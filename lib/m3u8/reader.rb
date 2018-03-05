# frozen_string_literal: true
module M3u8
  # Reader provides parsing of m3u8 playlists
  class Reader
    include M3u8
    attr_accessor :playlist, :item, :open, :master, :tags

    def initialize(*)
      @tags = [basic_tags,
               media_segment_tags,
               media_playlist_tags,
               master_playlist_tags,
               universal_tags].inject(:merge)
    end

    def read(input)
      @playlist = Playlist.new
      input.each_line.with_index do |line, index|
        validate_file_format(line) if index.zero?
        parse_line(line)
      end
      playlist
    end

    private

    def basic_tags
      { '#EXT-X-VERSION' => ->(line) { parse_version(line) } }
    end

    def media_segment_tags
      {
        '#EXTINF' => ->(line) { parse_segment(line) },
        '#EXT-X-DISCONTINUITY' => ->(line) { parse_discontinuity(line) },
        '#EXT-X-BYTERANGE' => ->(line) { parse_byterange(line) },
        '#EXT-X-KEY' => ->(line) { parse_key(line) },
        '#EXT-X-MAP' => ->(line) { parse_map(line) },
        '#EXT-X-PROGRAM-DATE-TIME' => ->(line) { parse_time(line) },
        '#EXT-X-DATERANGE' => ->(line) { parse_date_range(line) }
      }
    end

    def media_playlist_tags
      {
        '#EXT-X-MEDIA-SEQUENCE' => ->(line) { parse_sequence(line) },
        '#EXT-X-DISCONTINUITY-SEQUENCE' => lambda do |line|
          parse_discontinuity_sequence(line)
        end,
        '#EXT-X-ALLOW-CACHE' => ->(line) { parse_cache(line) },
        '#EXT-X-TARGETDURATION' => ->(line) { parse_target(line) },
        '#EXT-X-I-FRAMES-ONLY' => proc { playlist.iframes_only = true },
        '#EXT-X-PLAYLIST-TYPE' => ->(line) { parse_playlist_type(line) }
      }
    end

    def master_playlist_tags
      {
        '#EXT-X-MEDIA' => ->(line) { parse_media(line) },
        '#EXT-X-SESSION-DATA' => ->(line) { parse_session_data(line) },
        '#EXT-X-SESSION-KEY' => ->(line) { parse_session_key(line) },
        '#EXT-X-STREAM-INF' => ->(line) { parse_stream(line) },
        '#EXT-X-I-FRAME-STREAM-INF' => ->(line) { parse_iframe_stream(line) }
      }
    end

    def universal_tags
      {
        '#EXT-X-START' => ->(line) { parse_start(line) },
        '#EXT-X-INDEPENDENT-SEGMENTS' => proc do
          playlist.independent_segments = true
        end
      }
    end

    def parse_line(line)
      return if match_tag(line)
      parse_next_line(line) if !item.nil? && open
    end

    def match_tag(line)
      tag = @tags.select do |key|
        line.start_with?(key) && !line.start_with?("#{key}-")
      end

      return unless tag.values.first
      tag.values.first.call(line)
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

      self.item = M3u8::PlaylistItem.parse(line)
    end

    def parse_iframe_stream(line)
      self.master = true
      self.open = false

      self.item = M3u8::PlaylistItem.parse(line)
      item.iframe = true
      playlist.items << item
    end

    def parse_discontinuity(*)
      self.master = false
      self.open = false

      self.item = M3u8::DiscontinuityItem.new
      playlist.items << item
    end

    def parse_discontinuity_sequence(line)
      value = line.gsub('#EXT-X-DISCONTINUITY-SEQUENCE:', '').strip
      playlist.discontinuity_sequence = Integer(value)
    end

    def parse_key(line)
      item = M3u8::KeyItem.parse(line)
      playlist.items << item
    end

    def parse_map(line)
      item = M3u8::MapItem.parse(line)
      playlist.items << item
    end

    def parse_segment(line)
      self.item = M3u8::SegmentItem.new
      values = line.gsub('#EXTINF:', '').tr("\n", ',').split(',')
      item.duration = values[0].to_f
      values[0].scan(/[a-zA-Z0-9]+-[a-zA-Z0-9]+="[^"]+"/).each do |value|
        m = value.split('=')[0].tr('-', '_') + '='
        v = value.split('=')[1].delete('"', '')
        item.public_send(m, v) if item.class.method_defined? m
      end
      item.comment = values[1] unless values[1].nil?

      self.master = false
      self.open = true
    end

    def parse_byterange(line)
      values = line.gsub('#EXT-X-BYTERANGE:', '').delete("\n")
      item.byterange = M3u8::ByteRange.parse values
    end

    def parse_session_data(line)
      item = M3u8::SessionDataItem.parse(line)
      playlist.items << item
    end

    def parse_session_key(line)
      item = M3u8::SessionKeyItem.parse(line)
      playlist.items << item
    end

    def parse_media(line)
      self.open = false
      self.item = M3u8::MediaItem.parse(line)
      playlist.items << item
    end

    def parse_start(line)
      item = M3u8::PlaybackStart.new
      item.parse(line)
      playlist.items << item
    end

    def parse_time(line)
      if open
        item.program_date_time = M3u8::TimeItem.parse(line)
      else
        self.open = false
        playlist.items << M3u8::TimeItem.parse(line)
      end
    end

    def parse_date_range(line)
      item = M3u8::DateRangeItem.new
      item.parse(line)
      playlist.items << item
    end

    def parse_next_line(line)
      value = line.delete("\n").delete("\r")
      if master
        item.uri = value
      else
        item.segment = value
      end
      playlist.items << item
      self.open = false
    end

    def validate_file_format(line)
      return if line.rstrip == '#EXTM3U'
      message = 'Playlist must start with a #EXTM3U tag, line read ' \
                "contained the value: #{line}"
      raise InvalidPlaylistError, message
    end
  end
end
