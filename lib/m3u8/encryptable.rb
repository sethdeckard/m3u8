# frozen_string_literal: true

module M3u8
  # Encapsulates logic common to encryption key tags.
  # Adds :method, :uri, :iv, :key_format, and
  # :key_format_versions accessors when included.
  module Encryptable
    include AttributeFormatter

    # @!attribute [rw] method
    #   @return [String, nil] encryption method
    # @!attribute [rw] uri
    #   @return [String, nil] key URI
    # @!attribute [rw] iv
    #   @return [String, nil] initialization vector
    # @!attribute [rw] key_format
    #   @return [String, nil] KEYFORMAT value
    # @!attribute [rw] key_format_versions
    #   @return [String, nil] KEYFORMATVERSIONS value
    def self.included(base)
      base.send :attr_accessor, :method
      base.send :attr_accessor, :uri
      base.send :attr_accessor, :iv
      base.send :attr_accessor, :key_format
      base.send :attr_accessor, :key_format_versions
    end

    # Render encryption attributes as a comma-separated string.
    # @return [String]
    def attributes_to_s
      [unquoted_format('METHOD', method),
       quoted_format('URI', uri),
       unquoted_format('IV', iv),
       quoted_format('KEYFORMAT', key_format),
       quoted_format('KEYFORMATVERSIONS',
                     key_format_versions)].compact.join(',')
    end

    # Map HLS attribute names to Ruby symbol keys.
    # @param attributes [Hash] raw attribute hash
    # @return [Hash] symbolized options
    def convert_key_names(attributes)
      { method: attributes['METHOD'], uri: attributes['URI'],
        iv: attributes['IV'], key_format: attributes['KEYFORMAT'],
        key_format_versions: attributes['KEYFORMATVERSIONS'] }
    end
  end
end
