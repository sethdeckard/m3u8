# frozen_string_literal: true

module M3u8
  # Represents a time_signal SCTE-35 command (type 0x06)
  class Scte35TimeSignal
    attr_reader :pts_time

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse_from(reader, _length)
      pts_time = Scte35.parse_splice_time(reader)
      new(pts_time: pts_time)
    end
  end
end
