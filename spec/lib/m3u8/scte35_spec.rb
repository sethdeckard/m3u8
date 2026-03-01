# frozen_string_literal: true

require 'spec_helper'

describe M3u8::Scte35 do
  describe '.parse' do
    it 'should parse a splice_null command' do
      # splice_info_section with splice_null (type 0x00):
      #   table_id=0xFC, section_length=17, protocol=0, pts_adjustment=0
      #   cw_index=0, tier=0xFFF, command_length=0, command_type=0x00
      #   descriptor_loop_length=0, crc=0xDEADBEEF
      hex = '0xFC301100000000000000FFF000000000DEADBEEF'
      result = described_class.parse(hex)

      expect(result.table_id).to eq(0xFC)
      expect(result.pts_adjustment).to eq(0)
      expect(result.tier).to eq(0xFFF)
      expect(result.splice_command_type).to eq(0x00)
      expect(result.splice_command).to be_a(M3u8::Scte35SpliceNull)
      expect(result.descriptors).to eq([])
    end

    it 'should round-trip hex string via to_s' do
      hex = '0xFC301100000000000000FFF000000000DEADBEEF'
      result = described_class.parse(hex)
      expect(result.to_s).to eq(hex)
    end

    it 'should store raw bytes for unknown command types' do
      # command_type=0xFF with 2 bytes of command data (0xAABB)
      # section_length=19 to accommodate extra 2 bytes
      hex = '0xFC301300000000000000FFF002FFAABB0000DEADBEEF'
      result = described_class.parse(hex)

      expect(result.splice_command_type).to eq(0xFF)
      expect(result.splice_command).to eq("\xAA\xBB".b)
    end

    it 'should parse nonzero pts_adjustment' do
      # pts_adjustment=300 (0x12C): encrypted=0, algo=0, pts=300
      # 0_000000_0_00000000_00000000_00000001_00101100
      # bytes: 00 00 00 01 2C
      hex = '0xFC301100000000012C00FFF000000000DEADBEEF'
      result = described_class.parse(hex)

      expect(result.pts_adjustment).to eq(300)
    end

    it 'should handle hex strings without 0x prefix' do
      hex = 'FC301100000000000000FFF000000000DEADBEEF'
      result = described_class.parse(hex)

      expect(result.table_id).to eq(0xFC)
      expect(result.splice_command_type).to eq(0x00)
    end

    it 'should parse descriptors with 0xFFF command length' do
      # time_signal (type 0x06) with splice_command_length=0xFFF
      # and a descriptor present
      # time_signal: time_specified=1, pts=90000 (5 bytes)
      # descriptor: tag=0xFF, length=6, identifier=CUEI, data=0xAABB
      hex = '0xFC301E00000000000000FFFFFF06FE00015F900008FF0643554549AABBDEADBEEF'
      result = described_class.parse(hex)

      expect(result.splice_command_type).to eq(0x06)
      expect(result.splice_command.pts_time).to eq(90_000)
      expect(result.descriptors.length).to eq(1)
      expect(result.descriptors.first).to be_a(String)
    end

    it 'should consume remaining bytes for unknown type with 0xFFF' do
      # unknown command type 0xFF with 0xFFF length
      # command data is everything up to CRC (no descriptors per spec)
      # section_length = 11(header) + 3(command) + 4(CRC) = 18
      hex = '0xFC301200000000000000FFFFFFFFAABBCCDEADBEEF'
      result = described_class.parse(hex)

      expect(result.splice_command_type).to eq(0xFF)
      expect(result.splice_command).to eq("\xAA\xBB\xCC".b)
      expect(result.descriptors).to eq([])
    end

    it 'should raise ParseError for truncated data' do
      hex = '0xFC30'
      expect { described_class.parse(hex) }
        .to raise_error(M3u8::Scte35::ParseError, /invalid SCTE-35 data/)
    end

    it 'should raise ParseError for empty hex string' do
      expect { described_class.parse('0x') }
        .to raise_error(M3u8::Scte35::ParseError, /invalid SCTE-35 data/)
    end
  end
end
