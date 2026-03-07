# frozen_string_literal: true

module M3u8
  # Parses SCTE-35 splice_info_section binary payloads from hex strings
  class Scte35
    class ParseError < StandardError; end

    attr_reader :table_id, :pts_adjustment, :tier,
                :splice_command_type, :splice_command, :descriptors

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(hex_string)
      raw = hex_string.sub(/\A0x/i, '')
      data = [raw].pack('H*')
      reader = Scte35BitReader.new(data)

      header = parse_header(reader)
      command = parse_command(reader, header)
      descriptors = parse_descriptors(reader, header)

      args = header.merge(splice_command: command,
                          descriptors: descriptors, raw: hex_string)
      new(**args)
    rescue NoMethodError, ArgumentError => e
      raise ParseError, "invalid SCTE-35 data: #{e.message}"
    end

    def to_s
      @raw
    end

    def self.parse_header(reader)
      table_id = reader.read_bits(8)
      reader.skip_bits(4) # section_syntax_indicator, private, reserved
      section_length = reader.read_bits(12)
      reader.read_bits(8) # protocol_version
      reader.read_flag    # encrypted_packet
      reader.read_bits(6) # encryption_algorithm
      pts_adjustment = reader.read_bits(33)
      reader.read_bits(8) # cw_index
      tier = reader.read_bits(12)
      splice_command_length = reader.read_bits(12)
      splice_command_type = reader.read_bits(8)

      { table_id: table_id, pts_adjustment: pts_adjustment,
        tier: tier, splice_command_type: splice_command_type,
        splice_command_length: splice_command_length,
        section_length: section_length }
    end

    def self.parse_command(reader, header)
      cmd_length = command_data_length(reader, header)

      case header[:splice_command_type]
      when 0x00 then Scte35SpliceNull.new
      when 0x05 then Scte35SpliceInsert.parse_from(reader, cmd_length)
      when 0x06 then Scte35TimeSignal.parse_from(reader, cmd_length)
      else reader.read_bytes(cmd_length)
      end
    end

    def self.parse_splice_time(reader)
      unless reader.read_flag # time_specified
        reader.skip_bits(7) # reserved
        return nil
      end

      reader.skip_bits(6) # reserved
      reader.read_bits(33)
    end

    def self.parse_descriptors(reader, header)
      # For unknown commands with 0xFFF, command consumed all
      # remaining bytes (per spec), so no descriptors to parse
      return [] if unknown_command_with_unspecified_length?(header)

      desc_loop_length = reader.read_bits(16)
      parse_descriptor_loop(reader, desc_loop_length)
    end

    def self.unknown_command_with_unspecified_length?(header)
      header[:splice_command_length] == 0xFFF &&
        ![0x00, 0x05, 0x06].include?(header[:splice_command_type])
    end

    def self.parse_descriptor_loop(reader, remaining)
      descriptors = []
      while remaining.positive?
        tag = reader.read_bits(8)
        length = reader.read_bits(8)
        remaining -= 2 + length
        descriptors << parse_single_descriptor(reader, tag, length)
      end
      descriptors
    end

    def self.parse_single_descriptor(reader, tag, length)
      identifier = reader.read_bits(32)
      if tag == Scte35SegmentationDescriptor::DESCRIPTOR_TAG &&
         identifier == Scte35SegmentationDescriptor::CUEI_IDENTIFIER
        Scte35SegmentationDescriptor.parse_from(reader, length)
      else
        reader.read_bytes(length - 4)
      end
    end

    def self.command_data_length(reader, header)
      length = header[:splice_command_length]
      return length unless length == 0xFFF

      if unknown_command_with_unspecified_length?(header)
        # Unknown command: consume everything up to CRC
        reader.bytes_remaining - 4
      else
        # Known command types parse their own fields; length unused
        0
      end
    end

    private_class_method :parse_header, :parse_command,
                         :parse_descriptors, :command_data_length,
                         :parse_descriptor_loop, :parse_single_descriptor,
                         :unknown_command_with_unspecified_length?
  end
end
