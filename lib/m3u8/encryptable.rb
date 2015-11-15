module M3u8
  # Encapsulates logic common to encryption key tags
  module Encryptable
    def self.included(base)
      base.send :attr_accessor, :method
      base.send :attr_accessor, :uri
      base.send :attr_accessor, :iv
      base.send :attr_accessor, :key_format
      base.send :attr_accessor, :key_format_versions
    end

    def attributes_to_s
      [method_format,
       uri_format,
       iv_format,
       key_format_format,
       key_format_versions_format].compact.join(',')
    end

    def convert_key_names(attributes)
      { method: attributes['METHOD'], uri: attributes['URI'],
        iv: attributes['IV'], key_format: attributes['KEYFORMAT'],
        key_format_versions: attributes['KEYFORMATVERSIONS'] }
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
