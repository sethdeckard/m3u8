# frozen_string_literal: true

module M3u8
  # Parses SCTE-35 splice_info_section binary payloads from hex strings
  class Scte35
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
      cmd_length = command_data_length(header)

      case header[:splice_command_type]
      when 0x00 then Scte35SpliceNull.new
      when 0x05 then Scte35SpliceInsert.parse_from(reader, cmd_length)
      else reader.read_bytes(cmd_length)
      end
    end

    def self.parse_descriptors(reader, header)
      return [] if header[:splice_command_length] == 0xFFF

      reader.read_bits(16) # descriptor_loop_length
      []
    end

    def self.command_data_length(header)
      if header[:splice_command_length] == 0xFFF
        header[:section_length] - 15
      else
        header[:splice_command_length]
      end
    end

    private_class_method :parse_header, :parse_command,
                         :parse_descriptors, :command_data_length
  end
end
