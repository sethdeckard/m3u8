module M3u8
  class Reader
    attr_accessor :playlist, :item, :open
    PLAYLIST_START = '#EXTM3U'
    VERSION_START = '#EXT-X-VERSION:'
    SEQUENCE_START = '#EXT-X-MEDIA-SEQUENCE:'
    CACHE_START = '#EXT-X-ALLOW-CACHE:'
    TARGET_START = '#EXT-X-TARGETDURATION:'
    STREAM_START = '#EXT-X-STREAM-INF:'
    SEGMENT_START = '#EXTINF:'
    PROGRAM_ID = 'PROGRAM-ID'
    RESOLUTION = 'RESOLUTION'
    CODECS = 'CODECS'
    BANDWIDTH = 'BANDWIDTH'

    def initialize
      self.playlist = Playlist.new
    end

    def read(input)
      input.each_line do |line|
        parse_line line
      end
      playlist
    end

    private

    def parse_line(line)
      return if line.start_with? PLAYLIST_START

      if line.start_with? VERSION_START
        parse_version line
      elsif line.start_with? SEQUENCE_START
        parse_sequence line
      elsif line.start_with? CACHE_START
        parse_cache line
      elsif line.start_with? TARGET_START
        parse_target line
      elsif line.start_with? STREAM_START
        parse_stream line
      elsif line.start_with? SEGMENT_START
        parse_segment line
      elsif !item.nil? && open
        parse_value(line)
      end
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

    def parse_yes_no(string)
      string == 'YES' ? true : false
    end

    def parse_target(line)
      playlist.target = line.gsub(TARGET_START, '').to_i
    end

    def parse_stream(line)
      playlist.master = true
      self.open = true

      self.item = M3u8::PlaylistItem.new
      line = line.gsub STREAM_START, ''
      attributes = line.scan(/([A-z-]+)\s*=\s*("[^"]*"|[^,]*)/)
      attributes.each do |pair|
        value = pair[1].gsub("\n", '').gsub('"', '')
        case pair[0]
        when PROGRAM_ID
          item.program_id = value
        when RESOLUTION
          parse_resolution value
        when CODECS
          item.codecs = value
        when BANDWIDTH
          item.bitrate = value
        end
      end
    end

    def parse_segment(line)
      playlist.master = false
      self.open = true

      self.item = M3u8::SegmentItem.new
      item.time = line.gsub(SEGMENT_START, '').gsub("\n", '').gsub(',', '')
        .to_f
    end

    def parse_resolution(resolution)
      item.width = resolution.split('x')[0]
      item.height = resolution.split('x')[1]
    end

    def parse_value(line)
      value = line.gsub "\n", ''
      if playlist.master?
        item.playlist = value
      else
        item.segment = value
      end
      playlist.items.push item
      self.open = false
    end
  end
end
