# frozen_string_literal: true

module M3u8
  # Encapsulates logic common to encryption key tags
  module Encryptable
    include AttributeFormatter

    def self.included(base)
      base.send :attr_accessor, :method
      base.send :attr_accessor, :uri
      base.send :attr_accessor, :iv
      base.send :attr_accessor, :key_format
      base.send :attr_accessor, :key_format_versions
    end

    def attributes_to_s
      [unquoted_format('METHOD', method),
       quoted_format('URI', uri),
       unquoted_format('IV', iv),
       quoted_format('KEYFORMAT', key_format),
       quoted_format('KEYFORMATVERSIONS',
                     key_format_versions)].compact.join(',')
    end

    def convert_key_names(attributes)
      { method: attributes['METHOD'], uri: attributes['URI'],
        iv: attributes['IV'], key_format: attributes['KEYFORMAT'],
        key_format_versions: attributes['KEYFORMATVERSIONS'] }
    end
  end
end
