# frozen_string_literal: true

module M3u8
  # Represents a splice_insert SCTE-35 command (type 0x05)
  class Scte35SpliceInsert
    attr_reader :splice_event_id, :splice_event_cancel_indicator,
                :out_of_network_indicator, :pts_time,
                :break_duration, :break_auto_return,
                :unique_program_id, :avail_num, :avails_expected

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse_from(reader, _length)
      attrs = { splice_event_id: reader.read_bits(32) }
      attrs[:splice_event_cancel_indicator] = reader.read_flag
      reader.skip_bits(7) # reserved
      return new(**attrs) if attrs[:splice_event_cancel_indicator]

      parse_splice_detail(reader, attrs)
    end

    def self.parse_splice_detail(reader, attrs)
      attrs[:out_of_network_indicator] = reader.read_flag
      program_splice = reader.read_flag
      duration_flag = reader.read_flag
      immediate = reader.read_flag
      reader.skip_bits(4) # reserved

      if program_splice
        attrs[:pts_time] = parse_splice_time(reader) unless immediate
      else
        parse_components(reader, immediate)
      end
      parse_break_duration(reader, attrs) if duration_flag
      attrs[:unique_program_id] = reader.read_bits(16)
      attrs[:avail_num] = reader.read_bits(8)
      attrs[:avails_expected] = reader.read_bits(8)
      new(**attrs)
    end

    def self.parse_splice_time(reader)
      return nil unless reader.read_flag # time_specified

      reader.skip_bits(6) # reserved
      reader.read_bits(33)
    end

    def self.parse_components(reader, immediate)
      component_count = reader.read_bits(8)
      component_count.times do
        reader.read_bits(8) # component_tag
        parse_splice_time(reader) unless immediate
      end
    end

    def self.parse_break_duration(reader, attrs)
      attrs[:break_auto_return] = reader.read_flag
      reader.skip_bits(6) # reserved
      attrs[:break_duration] = reader.read_bits(33)
    end

    private_class_method :parse_splice_detail, :parse_splice_time,
                         :parse_break_duration, :parse_components
  end
end
