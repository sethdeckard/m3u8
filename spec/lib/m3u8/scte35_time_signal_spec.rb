# frozen_string_literal: true

require 'spec_helper'

describe M3u8::Scte35TimeSignal do
  def build_time_signal_hex(command_bytes, command_length: nil)
    cmd_len = command_length || command_bytes.length
    section_length = 11 + cmd_len + 6
    header = splice_info_header(section_length, cmd_len)
    command_hex = command_bytes.map { |b| format('%02X', b) }.join
    "0x#{header}06#{command_hex}0000DEADBEEF"
  end

  def splice_info_header(section_length, cmd_length)
    table_id = 'FC'
    section_header = format('%04X', 0x3000 | section_length)
    proto_and_pts = '000000000000'
    cw_index = '00'
    tier_cmd = format('%06X', (0xFFF << 12) | cmd_length)
    "#{table_id}#{section_header}#{proto_and_pts}#{cw_index}#{tier_cmd}"
  end

  describe '.parse_from' do
    it 'should parse time_signal with PTS time' do
      # splice_time: time_specified(1)=1, reserved(6)=111111, pts(33)=90000
      # 90000 = 0x15F90
      # 1_111111_0_00000000_00000001_01011111_10010000
      # = FE 00 01 5F 90
      command_bytes = [0xFE, 0x00, 0x01, 0x5F, 0x90]
      hex = build_time_signal_hex(command_bytes)
      result = M3u8::Scte35.parse(hex)
      cmd = result.splice_command

      expect(cmd).to be_a(described_class)
      expect(cmd.pts_time).to eq(90_000)
    end

    it 'should parse time_signal without time_specified' do
      # time_specified(1)=0, reserved(7)=1111111
      # = 0x7F (1 byte)
      command_bytes = [0x7F]
      hex = build_time_signal_hex(command_bytes)
      result = M3u8::Scte35.parse(hex)
      cmd = result.splice_command

      expect(cmd).to be_a(described_class)
      expect(cmd.pts_time).to be_nil
    end
  end
end
