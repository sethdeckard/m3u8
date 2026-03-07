# frozen_string_literal: true

module M3u8
  # RenditionReportItem represents an EXT-X-RENDITION-REPORT tag which
  # carries information about associated renditions in LL-HLS.
  class RenditionReportItem
    extend M3u8
    include AttributeFormatter

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

    def to_s
      "#EXT-X-RENDITION-REPORT:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      [quoted_format('URI', uri),
       unquoted_format('LAST-MSN', last_msn),
       unquoted_format('LAST-PART', last_part)].compact.join(',')
    end
  end
end
