# frozen_string_literal: true

module M3u8
  # DefineItem represents an EXT-X-DEFINE tag which provides variable
  # definitions for variable substitution. Supports three mutually
  # exclusive modes: NAME/VALUE, IMPORT, or QUERYPARAM.
  class DefineItem
    extend M3u8

    # @return [String, nil] variable name
    # @return [String, nil] variable value
    # @return [String, nil] imported variable name
    # @return [String, nil] query parameter name
    attr_accessor :name, :value, :import, :queryparam

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      params.each do |key, val|
        instance_variable_set("@#{key}", val)
      end
    end

    # Parse an EXT-X-DEFINE tag.
    # @param text [String] raw tag line
    # @return [DefineItem]
    def self.parse(text)
      attributes = parse_attributes(text)
      DefineItem.new(
        name: attributes['NAME'],
        value: attributes['VALUE'],
        import: attributes['IMPORT'],
        queryparam: attributes['QUERYPARAM']
      )
    end

    # Render as an m3u8 EXT-X-DEFINE tag.
    # @return [String]
    def to_s
      "#EXT-X-DEFINE:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      if import
        %(IMPORT="#{import}")
      elsif queryparam
        %(QUERYPARAM="#{queryparam}")
      else
        %(NAME="#{name}",VALUE="#{value}")
      end
    end
  end
end
