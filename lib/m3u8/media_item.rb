# frozen_string_literal: true

module M3u8
  # MediaItem represents a set of EXT-X-MEDIA attributes
  class MediaItem
    extend M3u8
    include AttributeFormatter

    # @return [String, nil] media type (AUDIO, VIDEO, etc.)
    # @return [String, nil] group ID
    # @return [String, nil] language tag (RFC 5646)
    # @return [String, nil] associated language tag
    # @return [String, nil] rendition name
    # @return [Boolean, nil] AUTOSELECT flag
    # @return [Boolean, nil] DEFAULT flag
    # @return [String, nil] rendition URI
    # @return [Boolean, nil] FORCED flag
    # @return [String, nil] instream ID for CC
    # @return [String, nil] media characteristics
    # @return [String, nil] audio channels
    # @return [String, nil] stable rendition ID
    # @return [Integer, nil] audio bit depth
    # @return [Integer, nil] audio sample rate
    attr_accessor :type, :group_id, :language, :assoc_language, :name,
                  :autoselect, :default, :uri, :forced, :instream_id,
                  :characteristics, :channels, :stable_rendition_id,
                  :bit_depth, :sample_rate

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-MEDIA tag.
    # @param text [String] raw tag line
    # @return [MediaItem]
    def self.parse(text)
      attributes = parse_attributes(text)
      options = { type: attributes['TYPE'],
                  group_id: attributes['GROUP-ID'],
                  language: attributes['LANGUAGE'],
                  assoc_language: attributes['ASSOC-LANGUAGE'],
                  name: attributes['NAME'],
                  autoselect: parse_yes_no(attributes['AUTOSELECT']),
                  default: parse_yes_no(attributes['DEFAULT']),
                  forced: parse_yes_no(attributes['FORCED']),
                  uri: attributes['URI'],
                  instream_id: attributes['INSTREAM-ID'],
                  characteristics: attributes['CHARACTERISTICS'],
                  channels: attributes['CHANNELS'],
                  stable_rendition_id:
                    attributes['STABLE-RENDITION-ID'],
                  bit_depth: parse_int(attributes['BIT-DEPTH']),
                  sample_rate: parse_int(attributes['SAMPLE-RATE']) }
      MediaItem.new(options)
    end

    # Render as an m3u8 EXT-X-MEDIA tag.
    # @return [String]
    def to_s
      "#EXT-X-MEDIA:#{formatted_attributes.join(',')}"
    end

    private

    def formatted_attributes
      ["TYPE=#{type}",
       %(GROUP-ID="#{group_id}"),
       quoted_format('LANGUAGE', language),
       quoted_format('ASSOC-LANGUAGE', assoc_language),
       %(NAME="#{name}"),
       boolean_format('AUTOSELECT', autoselect),
       boolean_format('DEFAULT', default),
       quoted_format('URI', uri),
       boolean_format('FORCED', forced),
       quoted_format('INSTREAM-ID', instream_id),
       quoted_format('CHARACTERISTICS', characteristics),
       quoted_format('CHANNELS', channels),
       quoted_format('STABLE-RENDITION-ID', stable_rendition_id),
       unquoted_format('BIT-DEPTH', bit_depth),
       unquoted_format('SAMPLE-RATE', sample_rate)].compact
    end
  end
end
