module M3u8
  # KeyItem represents a set of EXT-X-SESSION-KEY attributes
  class SessionKeyItem
    extend M3u8
    attr_accessor :method, :uri, :iv, :key_format, :key_format_versions

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes text
      options = { method: attributes['METHOD'], uri: attributes['URI'],
                  iv: attributes['IV'], key_format: attributes['KEYFORMAT'],
                  key_format_versions: attributes['KEYFORMATVERSIONS'] }
      SessionKeyItem.new options
    end

    def to_s
      attributes = [method_format,
                    uri_format,
                    iv_format,
                    key_format_format,
                    key_format_versions_format].compact.join(',')
      "#EXT-X-SESSION-KEY:#{attributes}"
    end

    private

    def method_format
      "METHOD=#{method}"
    end

    def uri_format
      %(URI="#{uri}") unless uri.nil?
    end

    def iv_format
      "IV=#{iv}" unless iv.nil?
    end

    def key_format_format
      %(KEYFORMAT="#{key_format}") unless key_format.nil?
    end

    def key_format_versions_format
      return if key_format_versions.nil?

      %(KEYFORMATVERSIONS="#{key_format_versions}")
    end
  end
end
