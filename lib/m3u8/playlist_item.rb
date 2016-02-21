module M3u8
  # PlaylistItem represents a set of EXT-X-STREAM-INF or
  # EXT-X-I-FRAME-STREAM-INF attributes
  class PlaylistItem
    extend M3u8
    attr_accessor :program_id, :width, :height, :codecs, :bandwidth,
                  :audio_codec, :level, :profile, :video, :audio, :uri,
                  :average_bandwidth, :subtitles, :closed_captions, :iframe,
                  :frame_rate
    MISSING_CODEC_MESSAGE = 'Audio or video codec info should be provided.'

    def initialize(params = {})
      self.iframe = false
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes text
      resolution = parse_resolution attributes['RESOLUTION']
      average = parse_average_bandwidth attributes['AVERAGE-BANDWIDTH']
      frame_rate = parse_frame_rate attributes['FRAME-RATE']
      options = { program_id: attributes['PROGRAM-ID'],
                  codecs: attributes['CODECS'],
                  width: resolution[:width],
                  height: resolution[:height],
                  bandwidth: attributes['BANDWIDTH'].to_i,
                  average_bandwidth: average,
                  frame_rate: frame_rate,
                  video: attributes['VIDEO'], audio: attributes['AUDIO'],
                  uri: attributes['URI'], subtitles: attributes['SUBTITLES'],
                  closed_captions: attributes['CLOSED-CAPTIONS'] }
      PlaylistItem.new options
    end

    def resolution
      return if width.nil?
      "#{width}x#{height}"
    end

    def codecs
      return @codecs unless @codecs.nil?

      video_codec = video_codec profile, level

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

    def to_s
      validate

      m3u8_format
    end

    private

    def self.parse_average_bandwidth(value)
      value.to_i unless value.nil?
    end

    def self.parse_resolution(resolution)
      return { width: nil, height: nil } if resolution.nil?

      values = resolution.split('x')
      width = values[0].to_i
      height = values[1].to_i
      { width: width, height: height }
    end

    def self.parse_frame_rate(frame_rate)
      return if frame_rate.nil?

      value = BigDecimal(frame_rate)
      value if value > 0
    end

    def validate
      fail MissingCodecError, MISSING_CODEC_MESSAGE if codecs.nil?
    end

    def m3u8_format
      return %(#EXT-X-I-FRAME-STREAM-INF:#{attributes},URI="#{uri}") if iframe

      "#EXT-X-STREAM-INF:#{attributes}\n#{uri}"
    end

    def attributes
      [program_id_format,
       resolution_format,
       codecs_format,
       bandwidth_format,
       average_bandwidth_format,
       frame_rate_format,
       audio_format,
       video_format,
       subtitles_format,
       closed_captions_format].compact.join(',')
    end

    def program_id_format
      return if program_id.nil?
      "PROGRAM-ID=#{program_id}"
    end

    def resolution_format
      return if resolution.nil?
      "RESOLUTION=#{resolution}"
    end

    def frame_rate_format
      return if frame_rate.nil?
      "FRAME-RATE=#{format('%.3f', frame_rate)}"
    end

    def codecs_format
      %(CODECS="#{codecs}")
    end

    def bandwidth_format
      "BANDWIDTH=#{bandwidth}"
    end

    def average_bandwidth_format
      return if average_bandwidth.nil?
      "AVERAGE-BANDWIDTH=#{average_bandwidth}"
    end

    def audio_format
      return if audio.nil?
      %(AUDIO="#{audio}")
    end

    def video_format
      return if video.nil?
      %(VIDEO="#{video}")
    end

    def subtitles_format
      return if subtitles.nil?
      %(SUBTITLES="#{subtitles}")
    end

    def closed_captions_format
      return if closed_captions.nil?
      %(CLOSED-CAPTIONS="#{closed_captions}")
    end

    def audio_codec
      return if @audio_codec.nil?
      return 'mp4a.40.2' if @audio_codec.downcase == 'aac-lc'
      return 'mp4a.40.5' if @audio_codec.downcase == 'he-aac'
      return 'mp4a.40.34' if @audio_codec.downcase == 'mp3'
    end

    def video_codec(profile, level)
      return if profile.nil? || level.nil?

      profile.downcase!
      return baseline_codec_string(level) if profile == 'baseline'
      return main_codec_string(level) if profile == 'main'
      return high_codec_string(level) if profile == 'high'
    end

    def baseline_codec_string(level)
      return 'avc1.66.30' if level == 3.0
      return 'avc1.42001f' if level == 3.1
    end

    def main_codec_string(level)
      return 'avc1.77.30' if level == 3.0
      return 'avc1.4d001f' if level == 3.1
      return 'avc1.4d0028' if level == 4.0
    end

    def high_codec_string(level)
      return 'avc1.64001f' if level == 3.1
      return 'avc1.640028' if level == 4.0
      return 'avc1.640029' if level == 4.1
    end
  end
end
