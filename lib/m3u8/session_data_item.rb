# frozen_string_literal: true

module M3u8
  # SessionDataItem represents a set of EXT-X-SESSION-DATA attributes
  class SessionDataItem
    extend M3u8

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
      attributes = [data_id_format,
                    value_format,
                    uri_format,
                    language_format].compact.join(',')
      "#EXT-X-SESSION-DATA:#{attributes}"
    end

    private

    def data_id_format
      %(DATA-ID="#{data_id}")
    end

    def value_format
      return if value.nil?

      %(VALUE="#{value}")
    end

    def uri_format
      return if uri.nil?

      %(URI="#{uri}")
    end

    def language_format
      return if language.nil?

      %(LANGUAGE="#{language}")
    end
  end
end
