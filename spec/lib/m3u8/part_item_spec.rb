# frozen_string_literal: true

require 'spec_helper'

describe M3u8::PartItem do
  describe '.new' do
    it 'assigns attributes from options' do
      options = { uri: 'part1.ts', duration: 1.5, independent: true,
                  gap: false }
      item = described_class.new(options)
      expect(item.uri).to eq('part1.ts')
      expect(item.duration).to eq(1.5)
      expect(item.independent).to be true
      expect(item.gap).to be false
    end
  end

  describe '.parse' do
    it 'parses tag with all attributes' do
      tag = '#EXT-X-PART:DURATION=1.5,URI="part1.ts",' \
            'INDEPENDENT=YES,BYTERANGE="500@0",GAP=YES'
      item = described_class.parse(tag)
      expect(item.duration).to eq(1.5)
      expect(item.uri).to eq('part1.ts')
      expect(item.independent).to be true
      expect(item.byterange.length).to eq(500)
      expect(item.byterange.start).to eq(0)
      expect(item.gap).to be true
    end

    it 'parses tag without optional attributes' do
      tag = '#EXT-X-PART:DURATION=1.5,URI="part1.ts"'
      item = described_class.parse(tag)
      expect(item.duration).to eq(1.5)
      expect(item.uri).to eq('part1.ts')
      expect(item.independent).to be false
      expect(item.byterange).to be_nil
      expect(item.gap).to be false
    end
  end

  describe '#to_s' do
    it 'returns tag with all attributes' do
      options = { duration: 1.5, uri: 'part1.ts', independent: true,
                  byterange: M3u8::ByteRange.new(length: 500, start: 0),
                  gap: true }
      item = described_class.new(options)
      expected = '#EXT-X-PART:DURATION=1.5,URI="part1.ts",' \
                 'INDEPENDENT=YES,BYTERANGE="500@0",GAP=YES'
      expect(item.to_s).to eq(expected)
    end

    it 'returns tag with only required attributes' do
      options = { duration: 1.5, uri: 'part1.ts' }
      item = described_class.new(options)
      expected = '#EXT-X-PART:DURATION=1.5,URI="part1.ts"'
      expect(item.to_s).to eq(expected)
    end
  end
end
