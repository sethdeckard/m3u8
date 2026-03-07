# frozen_string_literal: true

require 'bigdecimal'
require 'stringio'
Dir["#{File.dirname(__FILE__)}/m3u8/*.rb"].each { |file| require file }

# M3u8 provides parsing, generation, and validation of m3u8 playlists
module M3u8
  # Initialize attributes from a params hash, converting any Hash
  # values for :byterange into ByteRange instances.
  # @param params [Hash] attribute key-value pairs
  # @return [void]
  def initialize_with_byterange(params = {})
    params.each do |key, value|
      value = ByteRange.new(value) if value.is_a?(Hash)
      instance_variable_set("@#{key}", value)
    end
  end

  # Parse an HLS attribute list string into a Hash.
  # @param line [String] raw attribute list (e.g. 'KEY="val",NUM=1')
  # @return [Hash<String, String>] attribute name-value pairs
  def parse_attributes(line)
    line.delete("\n").scan(/([A-Za-z0-9-]+)\s*=\s*("[^"]*"|[^,]*)/)
        .to_h { |key, value| [key, value.delete('"')] }
  end

  # Convert a string value to Float, returning nil when nil.
  # @param value [String, nil] numeric string
  # @return [Float, nil]
  def parse_float(value)
    value&.to_f
  end

  # Convert a string value to Integer, returning nil when nil.
  # @param value [String, nil] numeric string
  # @return [Integer, nil]
  def parse_int(value)
    value&.to_i
  end

  # Parse an HLS YES/NO attribute into a boolean.
  # @param value [String] 'YES' or 'NO'
  # @return [Boolean]
  def parse_yes_no(value)
    value == 'YES'
  end

  # Convert a boolean into an HLS YES/NO string.
  # @param boolean [Boolean] value to convert
  # @return [String] 'YES' or 'NO'
  def to_yes_no(boolean)
    boolean == true ? 'YES' : 'NO'
  end
end
