# frozen_string_literal: true

module M3u8
  # DefineItem represents an EXT-X-DEFINE tag which provides variable
  # definitions for variable substitution. Supports three mutually
  # exclusive modes: NAME/VALUE, IMPORT, or QUERYPARAM.
  class DefineItem
    extend M3u8

    attr_accessor :name, :value, :import, :queryparam

    def initialize(params = {})
      params.each do |key, val|
        instance_variable_set("@#{key}", val)
      end
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      DefineItem.new(
        name: attributes['NAME'],
        value: attributes['VALUE'],
        import: attributes['IMPORT'],
        queryparam: attributes['QUERYPARAM']
      )
    end

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
