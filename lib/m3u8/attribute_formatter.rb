# frozen_string_literal: true

module M3u8
  # Shared helpers for formatting HLS tag attributes
  module AttributeFormatter
    def quoted_format(key, value)
      %(#{key}="#{value}") unless value.nil?
    end

    def unquoted_format(key, value)
      "#{key}=#{value}" unless value.nil?
    end

    def boolean_format(key, value)
      "#{key}=#{value == true ? 'YES' : 'NO'}" unless value.nil?
    end
  end
end
