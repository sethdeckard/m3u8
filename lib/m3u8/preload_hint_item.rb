# frozen_string_literal: true

module M3u8
  # PreloadHintItem represents an EXT-X-PRELOAD-HINT tag which allows
  # a server to indicate a resource that will be needed soon.
  class PreloadHintItem
    extend M3u8

    attr_accessor :type, :uri, :byterange_start, :byterange_length

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      PreloadHintItem.new(
        type: attributes['TYPE'],
        uri: attributes['URI'],
        byterange_start:
          parse_int(attributes['BYTERANGE-START']),
        byterange_length:
          parse_int(attributes['BYTERANGE-LENGTH'])
      )
    end

    def self.parse_int(value)
      value&.to_i
    end

    def to_s
      "#EXT-X-PRELOAD-HINT:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      [type_format,
       uri_format,
       byterange_start_format,
       byterange_length_format].compact.join(',')
    end

    def type_format
      "TYPE=#{type}"
    end

    def uri_format
      %(URI="#{uri}")
    end

    def byterange_start_format
      return if byterange_start.nil?

      "BYTERANGE-START=#{byterange_start}"
    end

    def byterange_length_format
      return if byterange_length.nil?

      "BYTERANGE-LENGTH=#{byterange_length}"
    end
  end
end
