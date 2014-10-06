module M3u8
  class Playlist
    attr_accessor :io, :header, :options

    def initialize options={}
      self.options = {
        :version => 3,
        :sequence => 0,
        :cache => true,
        :target => 10
        }.merge options

      @@empty = true
      @@master = nil
      self.io = StringIO.open
      io.puts "#EXTM3U"
    end

    def self.codecs options={}
      playlist = Playlist.new
      playlist.codecs options
    end

    def add_playlist program_id, playlist, bitrate, options={}
      options = {
        :width => nil,
        :height => nil,
        :profile => nil,
        :level => nil,
        :audio => nil
      }.merge options

      validate true
      @@master = true
      @@empty = false

      resolution = resolution options[:width], options[:height]
      codecs = codecs({:audio => options[:audio], :profile => options[:profile], :level => options[:level]})
      io.puts "#EXT-X-STREAM-INF:PROGRAM-ID=#{program_id},#{resolution}CODECS=""#{codecs}"",BANDWIDTH=#{bitrate}"
      io.puts playlist
    end

    def add_segment duration, segment
      validate false
      @@master = false
      @@empty = false

      unless header
        write_header
        self.header = true
      end

      io.puts "#EXTINF:#{duration},"
      io.puts segment
    end

    def codecs options={}
      options = {
        :audio => nil,
        :profile => nil,
        :level => nil
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

    def write output
      output.puts to_s
    end

    def master?
      if not @@empty
        return @@master
      end
      false
    end


    def to_s
      io.string
    end

    private

    def validate master
      unless @@empty
        if master and not master?
          raise PlaylistTypeError.new "Playlist is not a master playlist, playlist can not be added."
        elsif not master and master?
          raise PlaylistTypeError.new "Playlist is a master playlist, segment can not be added."
        end
      end
    end

    def write_header
      io.puts "#EXT-X-VERSION:#{options[:version]}"
      io.puts "#EXT-X-MEDIA-SEQUENCE:#{options[:sequence]}"
      io.puts "#EXT-X-ALLOW-CACHE:#{cache_string}"
      io.puts "#EXT-X-TARGETDURATION:#{options[:target]}"
    end

    def cache_string
      options[:cache] ? "YES" : "NO"
    end

    def audio_codec audio
      unless audio.nil?
        return 'mp4a.40.2' if audio.downcase == 'aac-lc'
        return 'mp4a.40.5' if audio.downcase == 'he-aac'
        return 'mp4a.40.34' if audio.downcase == 'mp3'
      end
    end

    def video_codec profile, level
      unless profile.nil? and level.nil?
        return 'avc1.66.30' if profile.downcase == 'baseline' and level == 3.0
        return 'avc1.42001f' if profile.downcase == 'baseline' and level == 3.1
        return 'avc1.77.30' if profile.downcase == 'main' and level == 3.0
        return 'avc1.4d001f' if profile.downcase == 'main' and level == 3.1
        return 'avc1.4d0028' if profile.downcase == 'main' and level == 4.0
        return 'avc1.64001f' if profile.downcase == 'high' and level == 3.1
        return 'avc1.640028' if profile.downcase == 'high' and (level == 4.0 or level == 4.1)
      end
    end

    def resolution width, height
      unless width.nil?
        "RESOLUTION=#{width}x#{height},"
      end
    end

  end
end