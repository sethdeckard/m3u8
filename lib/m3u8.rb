require 'stringio'
require 'm3u8/version'
require 'm3u8/playlist'
require 'm3u8/playlist_item'
require 'm3u8/segment_item'
require 'm3u8/discontinuity_item'
require 'm3u8/key_item'
require 'm3u8/map_item'
require 'm3u8/media_item'
require 'm3u8/time_item'
require 'm3u8/session_data_item'
require 'm3u8/byte_range'
require 'm3u8/reader'
require 'm3u8/writer'
require 'm3u8/error'

# M3u8 provides parsing, generation, and validation of m3u8 playlists
module M3u8
  def parse_attributes(line)
    array = line.gsub("\n", '').scan(/([A-z-]+)\s*=\s*("[^"]*"|[^,]*)/)
    Hash[array.map { |key, value| [key, value.gsub('"', '')] }]
  end

  def parse_yes_no(value)
    value == 'YES' ? true : false
  end

  def intialize_with_byterange(params = {})
    params.each do |key, value|
      value = ByteRange.new(value) if value.is_a?(Hash)
      instance_variable_set("@#{key}", value)
    end
  end
end
