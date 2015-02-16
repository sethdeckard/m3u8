module M3u8
  # Reader provides parsing of m3u8 playlists
  class Reader
    attr_accessor :playlist, :item, :open, :master
    PLAYLIST_START = '#EXTM3U'
    PLAYLIST_TYPE_START = '#EXT-X-PLAYLIST-TYPE:'
    VERSION_START = '#EXT-X-VERSION:'
    SEQUENCE_START = '#EXT-X-MEDIA-SEQUENCE:'
    CACHE_START = '#EXT-X-ALLOW-CACHE:'
    TARGET_START = '#EXT-X-TARGETDURATION:'
    IFRAME_START = '#EXT-X-I-FRAMES-ONLY'
    STREAM_START = '#EXT-X-STREAM-INF:'
    STREAM_IFRAME_START = '#EXT-X-I-FRAME-STREAM-INF:'
    MEDIA_START = '#EXT-X-MEDIA:'
    SESSION_DATA_START = '#EXT-X-SESSION-DATA:'
    KEY_START = '#EXT-X-KEY:'
    SEGMENT_START = '#EXTINF:'
    SEGMENT_DISCONTINUITY_TAG_START = '#EXT-X-DISCONTINUITY'
    BYTERANGE_START = '#EXT-X-BYTERANGE:'
    RESOLUTION = 'RESOLUTION'
    BANDWIDTH = 'BANDWIDTH'
    AVERAGE_BANDWIDTH = 'AVERAGE-BANDWIDTH'
    AUTOSELECT = 'AUTOSELECT'
    DEFAULT = 'DEFAULT'
    FORCED = 'FORCED'

    def read(input)
      self.playlist = Playlist.new
      input.each_line do |line|
        parse_line line
      end
      playlist
    end

    private

    def parse_line(line)
      return if line.start_with? PLAYLIST_START
      return if parse_master_playlist_tags line
      return if parse_segment_tags line
      return if parse_header_tags line
      parse_next_line line if !item.nil? && open
    end

    def parse_header_tags(line)
      if line.start_with? PLAYLIST_TYPE_START
        parse_playlist_type line
      elsif line.start_with? VERSION_START
        parse_version line
      elsif line.start_with? SEQUENCE_START
        parse_sequence line
      elsif line.start_with? CACHE_START
        parse_cache line
      elsif line.start_with? TARGET_START
        parse_target line
      elsif line.start_with? IFRAME_START
        playlist.iframes_only = true
      else
        return false
      end
    end

    def parse_master_playlist_tags(line)
      if line.start_with? STREAM_START
        parse_stream line
      elsif line.start_with? STREAM_IFRAME_START
        parse_iframe_stream line
      elsif line.start_with? MEDIA_START
        parse_media line
      elsif line.start_with? SEGMENT_DISCONTINUITY_TAG_START
        parse_segment_discontinuity_tag line
      elsif line.start_with? SESSION_DATA_START
        parse_session_data line
      else
        return false
      end
    end

    def parse_segment_tags(line)
      if line.start_with? KEY_START
        parse_key line
      elsif line.start_with? SEGMENT_START
        parse_segment line
      elsif line.start_with? BYTERANGE_START
        parse_byterange line
      else
        return false
      end
    end

    def parse_playlist_type(line)
      playlist.type = line.gsub(PLAYLIST_TYPE_START, '').delete!("\n")
    end

    def parse_version(line)
      playlist.version = line.gsub(VERSION_START, '').to_i
    end

    def parse_sequence(line)
      playlist.sequence = line.gsub(SEQUENCE_START, '').to_i
    end

    def parse_cache(line)
      line = line.gsub(CACHE_START, '')
      playlist.cache = parse_yes_no(line)
    end

    def parse_target(line)
      playlist.target = line.gsub(TARGET_START, '').to_i
    end

    def parse_stream(line)
      self.master = true
      self.open = true

      self.item = M3u8::PlaylistItem.new
      line = line.gsub STREAM_START, ''
      attributes = parse_attributes line
      parse_stream_attributes attributes
    end

    def parse_iframe_stream(line)
      self.master = true
      self.open = false

      self.item = M3u8::PlaylistItem.new
      item.iframe = true
      line = line.gsub STREAM_IFRAME_START, ''
      attributes = parse_attributes line
      parse_stream_attributes attributes
      playlist.items.push item
    end

    def parse_stream_attributes(attributes)
      attributes.each do |pair|
        name = pair[0]
        value = parse_value pair[1]
        case name
        when RESOLUTION
          parse_resolution value
        when BANDWIDTH
          item.bandwidth = value.to_i
        when AVERAGE_BANDWIDTH
          item.average_bandwidth = value.to_i
        else
          set_value name, value
        end
      end
    end

    def parse_segment_discontinuity_tag(*)
      self.master = false
      self.open = false

      self.item = M3u8::DiscontinuityItem.new
      playlist.items.push item
    end

    def parse_resolution(resolution)
      item.width = resolution.split('x')[0].to_i
      item.height = resolution.split('x')[1].to_i
    end

    def parse_key(line)
      item = M3u8::KeyItem.parse line
      playlist.items.push item
    end

    def parse_segment(line)
      self.item = M3u8::SegmentItem.new
      values = line.gsub(SEGMENT_START, '').gsub("\n", ',').split(',')
      item.duration = values[0].to_f
      item.comment = values[1] unless values[1].nil?

      self.master = false
      self.open = true
    end

    def parse_byterange(line)
      values = line.gsub(BYTERANGE_START, '').gsub("\n", ',').split '@'
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
      line = line.gsub MEDIA_START, ''
      attributes = parse_attributes line
      parse_media_attributes attributes
      playlist.items.push item
    end

    def parse_media_attributes(attributes)
      attributes.each do |pair|
        name = pair[0]
        value = parse_value pair[1]
        case name
        when AUTOSELECT
          item.autoselect = parse_yes_no value
        when DEFAULT
          item.default = parse_yes_no value
        when FORCED
          item.forced = parse_yes_no value
        else
          set_value name, value
        end
      end
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

    def parse_yes_no(string)
      string == 'YES' ? true : false
    end

    def parse_attributes(line)
      line.scan(/([A-z-]+)\s*=\s*("[^"]*"|[^,]*)/)
    end

    def parse_value(value)
      value.gsub("\n", '').gsub('"', '')
    end

    def set_value(name, value)
      name = name.downcase.gsub('-', '_')
      item.instance_variable_set("@#{name}", value)
    end
  end
end
