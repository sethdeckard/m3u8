# frozen_string_literal: true

module M3u8
  # Shared helpers for formatting HLS tag attributes
  module AttributeFormatter
    # Format a quoted attribute (e.g. KEY="value").
    # @param key [String] attribute name
    # @param value [Object, nil] attribute value
    # @return [String, nil] formatted string or nil when value is nil
    def quoted_format(key, value)
      %(#{key}="#{value}") unless value.nil?
    end

    # Format an unquoted attribute (e.g. KEY=value).
    # @param key [String] attribute name
    # @param value [Object, nil] attribute value
    # @return [String, nil] formatted string or nil when value is nil
    def unquoted_format(key, value)
      "#{key}=#{value}" unless value.nil?
    end

    # Format a YES/NO boolean attribute (e.g. KEY=YES).
    # @param key [String] attribute name
    # @param value [Boolean, nil] attribute value
    # @return [String, nil] formatted string or nil when value is nil
    def boolean_format(key, value)
      "#{key}=#{value == true ? 'YES' : 'NO'}" unless value.nil?
    end
  end
end
