# frozen_string_literal: true

require 'spec_helper'

describe M3u8::Scte35SpliceInsert do
  def build_splice_insert_hex(command_bytes, command_length: nil)
    cmd_len = command_length || command_bytes.length
    # section_length = 11(header) + cmd_len + 2(desc_loop) + 4(CRC)
    section_length = 11 + cmd_len + 6
    header = splice_info_header(section_length, cmd_len)
    command_hex = command_bytes.map { |b| format('%02X', b) }.join
    desc_and_crc = '0000DEADBEEF'
    "0x#{header}05#{command_hex}#{desc_and_crc}"
  end

  def splice_info_header(section_length, cmd_length)
    # table_id(8) + section_syntax(1)+private(1)+reserved(2)+section_length(12)
    # + protocol(8) + encrypted(1)+algo(6)+pts_adj(33) + cw_index(8)
    # + tier(12)+splice_command_length(12) + splice_command_type(8)
    byte0 = 'FC'
    bytes1_2 = format('%04X', 0x3000 | section_length)
    bytes3_8 = '000000000000' # protocol=0, encrypted=0, pts_adj=0
    byte9 = '00' # cw_index
    # tier=0xFFF, command_length
    tier_cmd = (0xFFF << 12) | cmd_length
    bytes10_12 = format('%06X', tier_cmd)
    "#{byte0}#{bytes1_2}#{bytes3_8}#{byte9}#{bytes10_12}"
  end

  describe '.parse_from' do
    it 'should parse an ad-start splice_insert' do
      # splice_event_id(32): 0x00000001
      # splice_event_cancel_indicator(1): 0
      # reserved(7): 1111111
      # out_of_network_indicator(1): 1
      # program_splice_flag(1): 1
      # duration_flag(1): 0
      # splice_immediate_flag(1): 0
      # reserved(4): 1111
      # splice_time: time_specified(1)=1, reserved(6)=111111, pts(33)=90000
      # unique_program_id(16): 0x0001
      # avail_num(8): 0
      # avails_expected(8): 0
      #
      # pts_time 90000 = 0x15F90:
      # time_specified(1)=1, reserved(6)=111111, pts(33)=0x00015F90
      # 1_111111_0_00000000_00000000_00010101_11111001_0000...
      # Wait, 33 bits of 90000 = 0x15F90:
      # binary: 0_00000000_00000001_01011111_10010000
      # with prefix: 1_111111_0_00000000_00000001_01011111_10010000
      # bytes: FE 00 00 01 5F 90 ... but that's 6 bytes (48 bits) for 40 bits
      #
      # Actually: 1+6+33 = 40 bits = 5 bytes:
      # 1_111111_0 00000000 00000001 01011111 10010000
      # = FE 00 01 5F 90
      command_bytes = [
        0x00, 0x00, 0x00, 0x01, # splice_event_id = 1
        0x7F,                   # cancel=0, reserved=1111111
        0xCF,                   # out=1, program=1, duration=0, immediate=0, reserved=1111
        0xFE, 0x00, 0x01, 0x5F, 0x90, # splice_time: specified=1, pts=90000
        0x00, 0x01,             # unique_program_id = 1
        0x00,                   # avail_num = 0
        0x00                    # avails_expected = 0
      ]
      hex = build_splice_insert_hex(command_bytes)
      result = M3u8::Scte35.parse(hex)
      cmd = result.splice_command

      expect(cmd).to be_a(described_class)
      expect(cmd.splice_event_id).to eq(1)
      expect(cmd.out_of_network_indicator).to be true
      expect(cmd.pts_time).to eq(90_000)
      expect(cmd.unique_program_id).to eq(1)
      expect(cmd.avail_num).to eq(0)
      expect(cmd.avails_expected).to eq(0)
    end

    it 'should parse a cancelled splice event' do
      command_bytes = [
        0x00, 0x00, 0x00, 0x02, # splice_event_id = 2
        0xFF                    # cancel=1, reserved=1111111
      ]
      hex = build_splice_insert_hex(command_bytes)
      result = M3u8::Scte35.parse(hex)
      cmd = result.splice_command

      expect(cmd.splice_event_id).to eq(2)
      expect(cmd.splice_event_cancel_indicator).to be true
      expect(cmd.out_of_network_indicator).to be_nil
      expect(cmd.pts_time).to be_nil
    end

    it 'should parse splice_insert with break duration' do
      # out=1, program=1, duration=1, immediate=0, reserved=1111
      # splice_time: specified=1, pts=90000
      # break_duration: auto_return(1)=1, reserved(6)=111111, duration(33)=2700000
      # 2700000 = 0x293370
      # 1_111111_0_00000000_00000000_00101001_00110011_01110000
      # Wait, 33 bits: 0_00000000_00101001_00110011_01110000
      # = 00 29 33 70 in the last 4 bytes, first byte has auto_return+reserved+MSB
      # 1_111111_0 00000000 00101001 00110011 01110000
      # = FE 00 29 33 70
      command_bytes = [
        0x00, 0x00, 0x00, 0x03, # splice_event_id = 3
        0x7F,                   # cancel=0, reserved=1111111
        0xEF,                   # out=1, program=1, duration=1, immediate=0, reserved=1111
        0xFE, 0x00, 0x01, 0x5F, 0x90, # splice_time: specified=1, pts=90000
        0xFE, 0x00, 0x29, 0x32, 0xE0, # break_duration: auto=1, dur=2700000
        0x00, 0x01,             # unique_program_id = 1
        0x00,                   # avail_num = 0
        0x02                    # avails_expected = 2
      ]
      hex = build_splice_insert_hex(command_bytes)
      result = M3u8::Scte35.parse(hex)
      cmd = result.splice_command

      expect(cmd.break_duration).to eq(2_700_000)
      expect(cmd.break_auto_return).to be true
      expect(cmd.avails_expected).to eq(2)
    end

    it 'should parse an immediate splice (no PTS)' do
      # out=1, program=1, duration=0, immediate=1, reserved=1111
      command_bytes = [
        0x00, 0x00, 0x00, 0x04, # splice_event_id = 4
        0x7F,                   # cancel=0, reserved=1111111
        0xDF,                   # out=1, program=1, duration=0, immediate=1, reserved=1111
        0x00, 0x01,             # unique_program_id = 1
        0x00,                   # avail_num = 0
        0x00                    # avails_expected = 0
      ]
      hex = build_splice_insert_hex(command_bytes)
      result = M3u8::Scte35.parse(hex)
      cmd = result.splice_command

      expect(cmd.pts_time).to be_nil
      expect(cmd.out_of_network_indicator).to be true
      expect(cmd.splice_event_id).to eq(4)
    end

    it 'should parse component mode splice_insert' do
      # out=1, program=0, duration=0, immediate=0, reserved=1111
      # 1_0_0_0_1111 = 0x8F
      # component_count=1, component_tag=0x22,
      # splice_time: specified=1, pts=90000
      command_bytes = [
        0x00, 0x00, 0x00, 0x01, # splice_event_id = 1
        0x7F,                   # cancel=0, reserved=1111111
        0x8F,                   # out=1, program=0, duration=0, immediate=0, reserved=1111
        0x01,                   # component_count = 1
        0x22,                   # component_tag = 0x22
        0xFE, 0x00, 0x01, 0x5F, 0x90, # splice_time: specified=1, pts=90000
        0x00, 0x01,             # unique_program_id = 1
        0x00,                   # avail_num = 0
        0x00                    # avails_expected = 0
      ]
      hex = build_splice_insert_hex(command_bytes)
      result = M3u8::Scte35.parse(hex)
      cmd = result.splice_command

      expect(cmd).to be_a(described_class)
      expect(cmd.splice_event_id).to eq(1)
      expect(cmd.out_of_network_indicator).to be true
      expect(cmd.pts_time).to be_nil
      expect(cmd.unique_program_id).to eq(1)
    end

    it 'should parse component mode with immediate flag' do
      # out=1, program=0, duration=0, immediate=1, reserved=1111
      # 1_0_0_1_1111 = 0x9F
      command_bytes = [
        0x00, 0x00, 0x00, 0x05, # splice_event_id = 5
        0x7F,                   # cancel=0, reserved=1111111
        0x9F,                   # out=1, program=0, duration=0, immediate=1, reserved=1111
        0x02,                   # component_count = 2
        0x10,                   # component_tag = 0x10
        0x20,                   # component_tag = 0x20
        0x00, 0x01,             # unique_program_id = 1
        0x00,                   # avail_num = 0
        0x00                    # avails_expected = 0
      ]
      hex = build_splice_insert_hex(command_bytes)
      result = M3u8::Scte35.parse(hex)
      cmd = result.splice_command

      expect(cmd.splice_event_id).to eq(5)
      expect(cmd.unique_program_id).to eq(1)
    end
  end
end
