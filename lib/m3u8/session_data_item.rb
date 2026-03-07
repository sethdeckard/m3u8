# frozen_string_literal: true

module M3u8
  # SessionDataItem represents a set of EXT-X-SESSION-DATA attributes
  class SessionDataItem
    extend M3u8
    include AttributeFormatter

    attr_accessor :data_id, :value, :uri, :language

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes text
      options = { data_id: attributes['DATA-ID'], value: attributes['VALUE'],
                  uri: attributes['URI'], language: attributes['LANGUAGE'] }
      M3u8::SessionDataItem.new options
    end

    def to_s
      attributes = [quoted_format('DATA-ID', data_id),
                    quoted_format('VALUE', value),
                    quoted_format('URI', uri),
                    quoted_format('LANGUAGE', language)].compact.join(',')
      "#EXT-X-SESSION-DATA:#{attributes}"
    end
  end
end
