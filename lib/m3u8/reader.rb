module M3u8
  class Reader
    attr_accessor :playlist, :item, :open, :master
    PLAYLIST_START = '#EXTM3U'
    PLAYLIST_TYPE_START = '#EXT-X-PLAYLIST-TYPE:'
    VERSION_START = '#EXT-X-VERSION:'
    SEQUENCE_START = '#EXT-X-MEDIA-SEQUENCE:'
    CACHE_START = '#EXT-X-ALLOW-CACHE:'
    TARGET_START = '#EXT-X-TARGETDURATION:'
    STREAM_START = '#EXT-X-STREAM-INF:'
    MEDIA_START = '#EXT-X-MEDIA:'
    SEGMENT_START = '#EXTINF:'
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

      if line.start_with? STREAM_START
        parse_stream line
      elsif line.start_with? SEGMENT_START
        parse_segment line
      elsif line.start_with? MEDIA_START
        parse_media line
      elsif !item.nil? && open
        parse_next_line line
      else
        parse_header line
      end
    end

    def parse_header(line)
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

    def parse_stream_attributes(attributes)
      attributes.each do |pair|
        value = parse_value pair[1]
        name = pair[0]
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

    def parse_resolution(resolution)
      item.width = resolution.split('x')[0].to_i
      item.height = resolution.split('x')[1].to_i
    end

    def parse_segment(line)
      self.master = false
      self.open = true

      self.item = M3u8::SegmentItem.new
      values = line.gsub(SEGMENT_START, '').gsub("\n", ',').split(',')
      item.duration = values[0].to_f
      item.comment = values[1] unless values[1].nil?
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
        value = parse_value pair[1]
        name = pair[0]
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
        item.playlist = value
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
