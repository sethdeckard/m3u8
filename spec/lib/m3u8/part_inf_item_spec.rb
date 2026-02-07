# frozen_string_literal: true

require 'spec_helper'

describe M3u8::PartInfItem do
  describe '.new' do
    it 'assigns attributes from options' do
      item = described_class.new(part_target: 0.5)
      expect(item.part_target).to eq(0.5)
    end
  end

  describe '.parse' do
    it 'parses tag' do
      tag = '#EXT-X-PART-INF:PART-TARGET=0.5'
      item = described_class.parse(tag)
      expect(item.part_target).to eq(0.5)
    end
  end

  describe '#to_s' do
    it 'returns m3u8 format representation' do
      item = described_class.new(part_target: 0.5)
      expect(item.to_s).to eq('#EXT-X-PART-INF:PART-TARGET=0.5')
    end
  end
end
