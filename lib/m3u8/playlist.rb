module M3u8
  class Playlist
    attr_accessor :master, :items, :version, :cache, :target, :sequence
    MISSING_CODEC_MESSAGE = 'An audio or video codec should be provided.'
    NON_MASTER_ERROR_MESSAGE = 'Playlist is not a master playlist, playlist' \
      ' can not be added.'
    MASTER_ERROR_MESSAGE = 'Playlist is a master playlist, segment can not ' \
      'be added.'

    def initialize(options = {})
      assign_options options

      self.master = nil
      self.items = []
    end

    def assign_options(options)
      options = {
        version: 3,
        sequence: 0,
        cache: true,
        target: 10
      }.merge options

      self.version = options[:version]
      self.sequence = options[:sequence]
      self.cache = options[:cache]
      self.target = options[:target]
    end

    def self.codecs(options = {})
      playlist = Playlist.new
      playlist.codecs options
    end

    def add_playlist(program_id, playlist, bitrate, options = {})
      options = {
        width: nil,
        height: nil,
        profile: nil,
        level: nil,
        audio: nil
      }.merge options

      validate_playlist_type true
      self.master = true

      codecs = codecs(audio: options[:audio], profile: options[:profile],
                      level: options[:level])
      fail MissingCodecError, MISSING_CODEC_MESSAGE if codecs.nil?

      params = { program_id: program_id, playlist: playlist, bitrate: bitrate,
                 width: options[:width], height: options[:height],
                 codecs: codecs }
      item = PlaylistItem.new params
      items.push item
    end

    def add_segment(duration, segment)
      validate_playlist_type false
      self.master = false

      params = { duration: duration, segment: segment }
      item = SegmentItem.new params
      items.push item
    end

    def codecs(options = {})
      options = {
        audio: nil,
        profile: nil,
        level: nil
      }.merge options

      audio_codec = audio_codec options[:audio]
      video_codec = video_codec options[:profile], options[:level]

      if video_codec.nil?
        return audio_codec
      else
        if audio_codec.nil?
          return video_codec
        else
          return "#{video_codec},#{audio_codec}"
        end
      end
    end

    def write(output)
      validate

      output.puts '#EXTM3U'
      write_header(output) unless master?

      items.each do |item|
        output.puts item.to_s
      end

      return if master?
      output.puts '#EXT-X-ENDLIST'
    end

    def master?
      return false if master.nil?
      master
    end

    def to_s
      output = StringIO.open
      write output
      output.string
    end

    def valid?
      playlists = items.select { |item| item.is_a?(PlaylistItem) }.size
      segments = items.select { |item| item.is_a?(SegmentItem) }.size

      return false if playlists > 0 && segments > 0
      true
    end

    private

    def validate
      return if valid?
      fail PlaylistTypeError, 'Playlist contains mixed types of items'
    end

    def validate_playlist_type(master)
      return if items.size == 0
      if master && !master?
        fail PlaylistTypeError, NON_MASTER_ERROR_MESSAGE
      elsif !master && master?
        fail PlaylistTypeError, MASTER_ERROR_MESSAGE
      end
    end

    def write_header(output)
      output.puts "#EXT-X-VERSION:#{version}"
      output.puts "#EXT-X-MEDIA-SEQUENCE:#{sequence}"
      output.puts "#EXT-X-ALLOW-CACHE:#{cache_string}"
      output.puts "#EXT-X-TARGETDURATION:#{target}"
    end

    def cache_string
      cache ? 'YES' : 'NO'
    end

    def audio_codec(audio)
      return if audio.nil?
      return 'mp4a.40.2' if audio.downcase == 'aac-lc'
      return 'mp4a.40.5' if audio.downcase == 'he-aac'
      return 'mp4a.40.34' if audio.downcase == 'mp3'
    end

    def video_codec(profile, level)
      return if profile.nil? || level.nil?

      profile = profile.downcase
      return 'avc1.66.30' if profile == 'baseline' && level == 3.0
      return 'avc1.42001f' if profile == 'baseline' && level == 3.1
      return 'avc1.77.30' if profile == 'main' && level == 3.0
      return 'avc1.4d001f' if profile == 'main' && level == 3.1
      return 'avc1.4d0028' if profile == 'main' && level == 4.0
      return 'avc1.64001f' if profile == 'high' && level == 3.1
      return 'avc1.640028' if profile == 'high' &&
                              (level == 4.0 || level == 4.1)
    end
  end
end
