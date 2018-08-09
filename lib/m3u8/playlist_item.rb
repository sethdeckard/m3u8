# frozen_string_literal: true
module M3u8
  # PlaylistItem represents a set of EXT-X-STREAM-INF or
  # EXT-X-I-FRAME-STREAM-INF attributes
  class PlaylistItem
    include M3u8
    attr_accessor :program_id, :width, :height, :codecs, :bandwidth,
                  :audio_codec, :level, :profile, :video, :audio, :uri,
                  :average_bandwidth, :subtitles, :closed_captions, :iframe,
                  :frame_rate, :name, :hdcp_level

    def initialize(params = {})
      self.iframe = false
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      item = PlaylistItem.new
      item.parse(text)
      item
    end

    def parse(text)
      attributes = parse_attributes(text)
      options = options_from_attributes(attributes)
      initialize(options)
    end

    def resolution
      return if width.nil?
      "#{width}x#{height}"
    end

    def codecs
      return @codecs unless @codecs.nil?

      video_codec_string = video_codec(profile, level)

      # profile and/or level were specified but not recognized,
      # do not specify any codecs
      return nil if !(profile.nil? && level.nil?) && video_codec_string.nil?

      audio_codec_string = audio_codec_code

      # audio codec was specified but not recognized,
      # do not specify any codecs
      return nil if !@audio_codec.nil? && audio_codec_string.nil?

      codec_strings = [video_codec_string, audio_codec_string].compact
      codec_strings.empty? ? nil : codec_strings.join(',')
    end

    def to_s
      m3u8_format
    end

    private

    def options_from_attributes(attributes)
      resolution = parse_resolution(attributes['RESOLUTION'])
      { program_id: attributes['PROGRAM-ID'],
        codecs: attributes['CODECS'],
        width: resolution[:width],
        height: resolution[:height],
        bandwidth: attributes['BANDWIDTH'].to_i,
        average_bandwidth:
          parse_average_bandwidth(attributes['AVERAGE-BANDWIDTH']),
        frame_rate: parse_frame_rate(attributes['FRAME-RATE']),
        video: attributes['VIDEO'], audio: attributes['AUDIO'],
        uri: attributes['URI'], subtitles: attributes['SUBTITLES'],
        closed_captions: attributes['CLOSED-CAPTIONS'],
        name: attributes['NAME'], hdcp_level: attributes['HDCP-LEVEL'] }
    end

    def parse_average_bandwidth(value)
      value.to_i unless value.nil?
    end

    def parse_resolution(resolution)
      return { width: nil, height: nil } if resolution.nil?

      values = resolution.split('x')
      width = values[0].to_i
      height = values[1].to_i
      { width: width, height: height }
    end

    def parse_frame_rate(frame_rate)
      return if frame_rate.nil?

      value = BigDecimal(frame_rate)
      value if value > 0
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
       hdcp_level_format,
       audio_format,
       video_format,
       subtitles_format,
       closed_captions_format,
       name_format].compact.join(',')
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

    def hdcp_level_format
      return if hdcp_level.nil?
      "HDCP-LEVEL=#{hdcp_level}"
    end

    def codecs_format
      return if codecs.nil?
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

      if closed_captions == 'NONE'
        %(CLOSED-CAPTIONS=NONE)
      else
        %(CLOSED-CAPTIONS="#{closed_captions}")
      end
    end

    def name_format
      return if name.nil?
      %(NAME="#{name}")
    end

    def audio_codec_code
      return if @audio_codec.nil?
      return 'mp4a.40.2' if @audio_codec.casecmp('aac-lc').zero?
      return 'mp4a.40.5' if @audio_codec.casecmp('he-aac').zero?
      return 'mp4a.40.34' if @audio_codec.casecmp('mp3').zero?
    end

    def video_codec(profile, level)
      return if profile.nil? || level.nil?

      return baseline_codec_string(level) if profile.casecmp('baseline').zero?
      return main_codec_string(level) if profile.casecmp('main').zero?
      return high_codec_string(level) if profile.casecmp('high').zero?
    end

    def baseline_codec_string(level)
      return 'avc1.66.30' if level == 3.0
      return 'avc1.42001f' if level == 3.1
    end

    def main_codec_string(level)
      return 'avc1.77.30' if level == 3.0
      return 'avc1.4d001f' if level == 3.1
      return 'avc1.4d0028' if level == 4.0
      return 'avc1.4d0029' if level == 4.1
    end

    def high_codec_string(level)
      return nil unless [3.0, 3.1, 3.2, 4.0, 4.1, 4.2, 5.0, 5.1, 5.2].include?(level)

      level_hex_string = level.to_s.sub('.', '').to_i.to_s(16)
      return "avc1.6400#{level_hex_string}"
    end
  end
end
