# frozen_string_literal: true

module M3u8
  # SessionDataItem represents a set of EXT-X-SESSION-DATA attributes
  class SessionDataItem
    extend M3u8
    include AttributeFormatter

    # @return [String, nil] DATA-ID value
    # @return [String, nil] VALUE attribute
    # @return [String, nil] URI attribute
    # @return [String, nil] LANGUAGE attribute
    attr_accessor :data_id, :value, :uri, :language

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-SESSION-DATA tag.
    # @param text [String] raw tag line
    # @return [SessionDataItem]
    def self.parse(text)
      attributes = parse_attributes text
      options = { data_id: attributes['DATA-ID'], value: attributes['VALUE'],
                  uri: attributes['URI'], language: attributes['LANGUAGE'] }
      M3u8::SessionDataItem.new options
    end

    # Render as an m3u8 EXT-X-SESSION-DATA tag.
    # @return [String]
    def to_s
      attributes = [quoted_format('DATA-ID', data_id),
                    quoted_format('VALUE', value),
                    quoted_format('URI', uri),
                    quoted_format('LANGUAGE', language)].compact.join(',')
      "#EXT-X-SESSION-DATA:#{attributes}"
    end
  end
end
