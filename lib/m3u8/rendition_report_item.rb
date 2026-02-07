# frozen_string_literal: true

module M3u8
  # RenditionReportItem represents an EXT-X-RENDITION-REPORT tag which
  # carries information about associated renditions in LL-HLS.
  class RenditionReportItem
    extend M3u8

    attr_accessor :uri, :last_msn, :last_part

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      RenditionReportItem.new(
        uri: attributes['URI'],
        last_msn: parse_int(attributes['LAST-MSN']),
        last_part: parse_int(attributes['LAST-PART'])
      )
    end

    def self.parse_int(value)
      value&.to_i
    end

    def to_s
      "#EXT-X-RENDITION-REPORT:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      [uri_format,
       last_msn_format,
       last_part_format].compact.join(',')
    end

    def uri_format
      %(URI="#{uri}")
    end

    def last_msn_format
      return if last_msn.nil?

      "LAST-MSN=#{last_msn}"
    end

    def last_part_format
      return if last_part.nil?

      "LAST-PART=#{last_part}"
    end
  end
end
