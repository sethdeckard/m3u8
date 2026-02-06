# frozen_string_literal: true

require 'bigdecimal'
require 'stringio'
Dir["#{File.dirname(__FILE__)}/m3u8/*.rb"].each { |file| require file }

# M3u8 provides parsing, generation, and validation of m3u8 playlists
module M3u8
  def intialize_with_byterange(params = {})
    params.each do |key, value|
      value = ByteRange.new(value) if value.is_a?(Hash)
      instance_variable_set("@#{key}", value)
    end
  end

  def parse_attributes(line)
    # rubocop:disable Style/HashTransformValues
    line.delete("\n").scan(/([A-Za-z0-9-]+)\s*=\s*("[^"]*"|[^,]*)/)
        .to_h { |key, value| [key, value.delete('"')] }
    # rubocop:enable Style/HashTransformValues
  end

  def parse_float(value)
    value&.to_f
  end

  def parse_yes_no(value)
    value == 'YES'
  end

  def to_yes_no(boolean)
    boolean == true ? 'YES' : 'NO'
  end
end
