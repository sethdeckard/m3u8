require 'stringio'
Dir[File.dirname(__FILE__) + '/m3u8/*.rb'].sort.each { |file| require file }

# M3u8 provides parsing, generation, and validation of m3u8 playlists
module M3u8
  def parse_attributes(line)
    array = line.delete("\n").scan(/([A-z-]+)\s*=\s*("[^"]*"|[^,]*)/)
    Hash[array.map { |key, value| [key, value.delete('"')] }]
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
