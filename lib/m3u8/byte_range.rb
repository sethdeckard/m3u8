# frozen_string_literal: true

module M3u8
  # ByteRange represents sub range of a resource
  class ByteRange
    # @return [Integer, nil] number of bytes
    # @return [Integer, nil] start offset in bytes
    attr_accessor :length, :start

    # @param params [Hash] :length and optional :start
    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse a byte range string (e.g. "4500@600").
    # @param text [String] byte range string
    # @return [ByteRange]
    def self.parse(text)
      values = text.split('@')
      length_value = values[0].to_i
      start_value = values[1].to_i unless values[1].nil?
      options = { length: length_value, start: start_value }
      ByteRange.new(options)
    end

    # Render as a byte range string (e.g. "4500@600").
    # @return [String]
    def to_s
      "#{length}#{start_format}"
    end

    private

    def start_format
      return if start.nil?

      "@#{start}"
    end
  end
end
