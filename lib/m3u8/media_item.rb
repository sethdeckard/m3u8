# frozen_string_literal: true

module M3u8
  # MediaItem represents a set of EXT-X-MEDIA attributes
  class MediaItem
    extend M3u8

    attr_accessor :type, :group_id, :language, :assoc_language, :name,
                  :autoselect, :default, :uri, :forced, :instream_id,
                  :characteristics, :channels, :stable_rendition_id,
                  :bit_depth, :sample_rate

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      options = { type: attributes['TYPE'], group_id: attributes['GROUP-ID'],
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
                  stable_rendition_id: attributes['STABLE-RENDITION-ID'],
                  bit_depth: parse_int(attributes['BIT-DEPTH']),
                  sample_rate: parse_int(attributes['SAMPLE-RATE']) }
      MediaItem.new(options)
    end

    def self.parse_int(value)
      value&.to_i
    end

    def to_s
      "#EXT-X-MEDIA:#{formatted_attributes.join(',')}"
    end

    private

    def formatted_attributes
      [type_format,
       group_id_format,
       language_format,
       assoc_language_format,
       name_format,
       autoselect_format,
       default_format,
       uri_format,
       forced_format,
       instream_id_format,
       characteristics_format,
       channels_format,
       stable_rendition_id_format,
       bit_depth_format,
       sample_rate_format].compact
    end

    def type_format
      "TYPE=#{type}"
    end

    def group_id_format
      %(GROUP-ID="#{group_id}")
    end

    def language_format
      return if language.nil?

      %(LANGUAGE="#{language}")
    end

    def assoc_language_format
      return if assoc_language.nil?

      %(ASSOC-LANGUAGE="#{assoc_language}")
    end

    def name_format
      %(NAME="#{name}")
    end

    def autoselect_format
      return if autoselect.nil?

      "AUTOSELECT=#{to_yes_no autoselect}"
    end

    def default_format
      return if default.nil?

      "DEFAULT=#{to_yes_no default}"
    end

    def uri_format
      return if uri.nil?

      %(URI="#{uri}")
    end

    def forced_format
      return if forced.nil?

      "FORCED=#{to_yes_no forced}"
    end

    def instream_id_format
      return if instream_id.nil?

      %(INSTREAM-ID="#{instream_id}")
    end

    def characteristics_format
      return if characteristics.nil?

      %(CHARACTERISTICS="#{characteristics}")
    end

    def channels_format
      return if channels.nil?

      %(CHANNELS="#{channels}")
    end

    def stable_rendition_id_format
      return if stable_rendition_id.nil?

      %(STABLE-RENDITION-ID="#{stable_rendition_id}")
    end

    def bit_depth_format
      return if bit_depth.nil?

      "BIT-DEPTH=#{bit_depth}"
    end

    def sample_rate_format
      return if sample_rate.nil?

      "SAMPLE-RATE=#{sample_rate}"
    end

    def to_yes_no(boolean)
      boolean == true ? 'YES' : 'NO'
    end
  end
end
