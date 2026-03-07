# frozen_string_literal: true

module M3u8
  # PlaylistItem represents a set of EXT-X-STREAM-INF or
  # EXT-X-I-FRAME-STREAM-INF attributes
  class PlaylistItem
    extend M3u8
    include AttributeFormatter

    # @return [String, nil] program ID
    # @return [Integer, nil] horizontal resolution in pixels
    # @return [Integer, nil] vertical resolution in pixels
    # @return [String, nil] codec string or computed codecs
    # @return [Integer, nil] peak bandwidth in bits/s
    # @return [String, nil] audio codec hint for codecs generation
    # @return [String, Integer, Float, nil] H.264/HEVC/AV1 level
    # @return [String, nil] H.264/HEVC/AV1 profile name
    # @return [String, nil] VIDEO rendition group ID
    # @return [String, nil] AUDIO rendition group ID
    # @return [String, nil] stream URI
    # @return [Integer, nil] average bandwidth in bits/s
    # @return [String, nil] SUBTITLES rendition group ID
    # @return [String, nil] CLOSED-CAPTIONS value or 'NONE'
    # @return [Boolean] whether this is an I-frame stream
    # @return [BigDecimal, nil] frame rate
    # @return [String, nil] stream name
    # @return [String, nil] HDCP level (TYPE-0, TYPE-1, NONE)
    # @return [String, nil] stable variant ID
    # @return [String, nil] video range (SDR, HLG, PQ)
    # @return [String, nil] allowed CPC value
    # @return [String, nil] content steering pathway ID
    # @return [String, nil] required video layout
    # @return [String, nil] supplemental codecs string
    # @return [Float, nil] stream score
    attr_accessor :program_id, :width, :height, :codecs, :bandwidth,
                  :audio_codec, :level, :profile, :video, :audio, :uri,
                  :average_bandwidth, :subtitles, :closed_captions, :iframe,
                  :frame_rate, :name, :hdcp_level, :stable_variant_id,
                  :video_range, :allowed_cpc, :pathway_id,
                  :req_video_layout, :supplemental_codecs, :score

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      self.iframe = false
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-STREAM-INF or EXT-X-I-FRAME-STREAM-INF tag.
    # @param text [String] raw tag line
    # @return [PlaylistItem]
    def self.parse(text)
      attributes = parse_attributes(text)
      options = options_from_attributes(attributes)
      PlaylistItem.new(options)
    end

    # Format the resolution as a WIDTHxHEIGHT string.
    # @return [String, nil]
    def resolution
      return if width.nil?

      "#{width}x#{height}"
    end

    # Return or compute the codecs string.
    # @return [String, nil]
    def codecs
      return @codecs unless @codecs.nil?

      video = Codecs.video_codec(profile, level)

      # profile and/or level were specified but not recognized
      return nil if !(profile.nil? && level.nil?) && video.nil?

      audio = Codecs.audio_codec(@audio_codec)

      # audio codec was specified but not recognized
      return nil if !@audio_codec.nil? && audio.nil?

      strings = [video, audio].compact
      strings.empty? ? nil : strings.join(',')
    end

    # Render as an m3u8 tag string.
    # @return [String]
    def to_s
      m3u8_format
    end

    def self.options_from_attributes(attributes)
      parse_stream_attrs(attributes)
        .merge(parse_media_attrs(attributes))
    end
    private_class_method :options_from_attributes

    def self.parse_stream_attrs(attributes)
      resolution = parse_resolution(attributes['RESOLUTION'])
      { program_id: attributes['PROGRAM-ID'],
        codecs: attributes['CODECS'],
        width: resolution[:width],
        height: resolution[:height],
        bandwidth:
          parse_bandwidth(attributes['BANDWIDTH']),
        average_bandwidth:
          parse_average_bandwidth(
            attributes['AVERAGE-BANDWIDTH']
          ),
        frame_rate:
          parse_frame_rate(attributes['FRAME-RATE']),
        hdcp_level: attributes['HDCP-LEVEL'],
        video_range: attributes['VIDEO-RANGE'],
        supplemental_codecs:
          attributes['SUPPLEMENTAL-CODECS'],
        score: parse_float(attributes['SCORE']) }
    end
    private_class_method :parse_stream_attrs

    def self.parse_media_attrs(attributes)
      { video: attributes['VIDEO'],
        audio: attributes['AUDIO'],
        uri: attributes['URI'],
        subtitles: attributes['SUBTITLES'],
        closed_captions: attributes['CLOSED-CAPTIONS'],
        name: attributes['NAME'],
        stable_variant_id:
          attributes['STABLE-VARIANT-ID'],
        allowed_cpc: attributes['ALLOWED-CPC'],
        pathway_id: attributes['PATHWAY-ID'],
        req_video_layout:
          attributes['REQ-VIDEO-LAYOUT'] }
    end
    private_class_method :parse_media_attrs

    def self.parse_average_bandwidth(value)
      value&.to_i
    end
    private_class_method :parse_average_bandwidth

    def self.parse_bandwidth(value)
      return if value.nil?

      value.to_i
    end
    private_class_method :parse_bandwidth

    def self.parse_resolution(resolution)
      return { width: nil, height: nil } if resolution.nil?

      values = resolution.split('x')
      width = values[0].to_i
      height = values[1].to_i
      { width: width, height: height }
    end
    private_class_method :parse_resolution

    def self.parse_frame_rate(frame_rate)
      return if frame_rate.nil?

      value = BigDecimal(frame_rate)
      value if value.positive?
    end
    private_class_method :parse_frame_rate

    private

    def m3u8_format
      return %(#EXT-X-I-FRAME-STREAM-INF:#{attributes},URI="#{uri}") if iframe

      "#EXT-X-STREAM-INF:#{attributes}\n#{uri}"
    end

    def attributes
      (stream_attributes + media_attributes).compact.join(',')
    end

    def stream_attributes
      [unquoted_format('PROGRAM-ID', program_id),
       unquoted_format('RESOLUTION', resolution),
       quoted_format('CODECS', codecs),
       quoted_format('SUPPLEMENTAL-CODECS', supplemental_codecs),
       "BANDWIDTH=#{bandwidth}",
       unquoted_format('AVERAGE-BANDWIDTH', average_bandwidth),
       unquoted_format('SCORE', score),
       frame_rate_format,
       unquoted_format('HDCP-LEVEL', hdcp_level),
       unquoted_format('VIDEO-RANGE', video_range)]
    end

    def media_attributes
      [quoted_format('ALLOWED-CPC', allowed_cpc),
       quoted_format('AUDIO', audio),
       quoted_format('VIDEO', video),
       quoted_format('SUBTITLES', subtitles),
       closed_captions_format,
       quoted_format('NAME', name),
       quoted_format('STABLE-VARIANT-ID', stable_variant_id),
       quoted_format('PATHWAY-ID', pathway_id),
       quoted_format('REQ-VIDEO-LAYOUT',
                     req_video_layout)]
    end

    def frame_rate_format
      return if frame_rate.nil?

      "FRAME-RATE=#{format('%.3f', frame_rate)}"
    end

    def closed_captions_format
      return if closed_captions.nil?

      if closed_captions == 'NONE'
        'CLOSED-CAPTIONS=NONE'
      else
        %(CLOSED-CAPTIONS="#{closed_captions}")
      end
    end
  end
end
