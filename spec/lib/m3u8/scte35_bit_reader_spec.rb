# frozen_string_literal: true

require 'spec_helper'

describe M3u8::Scte35BitReader do
  describe '#read_bits' do
    it 'should read 8-bit values' do
      reader = described_class.new("\xAB")
      expect(reader.read_bits(8)).to eq(0xAB)
    end

    it 'should read 1-bit values' do
      reader = described_class.new("\xA0")
      expect(reader.read_bits(1)).to eq(1)
      expect(reader.read_bits(1)).to eq(0)
      expect(reader.read_bits(1)).to eq(1)
      expect(reader.read_bits(1)).to eq(0)
    end

    it 'should read 12-bit values' do
      reader = described_class.new("\xAB\xCD")
      expect(reader.read_bits(12)).to eq(0xABC)
    end

    it 'should read 16-bit values' do
      reader = described_class.new("\xAB\xCD")
      expect(reader.read_bits(16)).to eq(0xABCD)
    end

    it 'should read 32-bit values' do
      reader = described_class.new("\x12\x34\x56\x78")
      expect(reader.read_bits(32)).to eq(0x12345678)
    end

    it 'should read 33-bit values' do
      # 1 followed by 32 zeros = 2^32
      reader = described_class.new("\x80\x00\x00\x00\x00")
      expect(reader.read_bits(33)).to eq(2**32)
    end

    it 'should read 33-bit values after partial byte reads' do
      # Simulates: time_specified(1), reserved(6), pts_time(33)
      # 1_111111_0 00000000 00000000 00000000 00000001
      reader = described_class.new("\xFE\x00\x00\x00\x01")
      expect(reader.read_bits(1)).to eq(1)
      expect(reader.read_bits(6)).to eq(0x3F)
      expect(reader.read_bits(33)).to eq(1)
    end

    it 'should read values across byte boundaries' do
      reader = described_class.new("\xF0\x0F")
      expect(reader.read_bits(4)).to eq(0xF)
      expect(reader.read_bits(8)).to eq(0x00)
      expect(reader.read_bits(4)).to eq(0xF)
    end
  end

  describe '#read_flag' do
    it 'should return true for 1' do
      reader = described_class.new("\x80")
      expect(reader.read_flag).to be true
    end

    it 'should return false for 0' do
      reader = described_class.new("\x00")
      expect(reader.read_flag).to be false
    end
  end

  describe '#read_bytes' do
    it 'should read raw bytes' do
      reader = described_class.new("\xDE\xAD\xBE\xEF")
      expect(reader.read_bytes(2)).to eq("\xDE\xAD".b)
      expect(reader.read_bytes(2)).to eq("\xBE\xEF".b)
    end
  end

  describe '#skip_bits' do
    it 'should advance the position' do
      reader = described_class.new("\xFF\x42")
      reader.skip_bits(8)
      expect(reader.read_bits(8)).to eq(0x42)
    end

    it 'should skip sub-byte amounts' do
      reader = described_class.new("\xF5")
      reader.skip_bits(4)
      expect(reader.read_bits(4)).to eq(0x5)
    end
  end

  describe '#bytes_remaining' do
    it 'should return remaining bytes' do
      reader = described_class.new("\x01\x02\x03\x04")
      expect(reader.bytes_remaining).to eq(4)
      reader.read_bits(8)
      expect(reader.bytes_remaining).to eq(3)
    end

    it 'should account for partial byte reads' do
      reader = described_class.new("\x01\x02")
      reader.read_bits(4)
      expect(reader.bytes_remaining).to eq(1)
    end
  end
end
