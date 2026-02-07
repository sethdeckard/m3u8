# frozen_string_literal: true

require 'spec_helper'

describe M3u8::PreloadHintItem do
  describe '.new' do
    it 'assigns attributes from options' do
      options = { type: 'PART', uri: 'next_part.ts',
                  byterange_start: 0, byterange_length: 5000 }
      item = described_class.new(options)
      expect(item.type).to eq('PART')
      expect(item.uri).to eq('next_part.ts')
      expect(item.byterange_start).to eq(0)
      expect(item.byterange_length).to eq(5000)
    end
  end

  describe '.parse' do
    it 'parses tag with all attributes' do
      tag = '#EXT-X-PRELOAD-HINT:TYPE=PART,URI="next_part.ts",' \
            'BYTERANGE-START=0,BYTERANGE-LENGTH=5000'
      item = described_class.parse(tag)
      expect(item.type).to eq('PART')
      expect(item.uri).to eq('next_part.ts')
      expect(item.byterange_start).to eq(0)
      expect(item.byterange_length).to eq(5000)
    end

    it 'parses tag without optional attributes' do
      tag = '#EXT-X-PRELOAD-HINT:TYPE=PART,URI="next_part.ts"'
      item = described_class.parse(tag)
      expect(item.type).to eq('PART')
      expect(item.uri).to eq('next_part.ts')
      expect(item.byterange_start).to be_nil
      expect(item.byterange_length).to be_nil
    end
  end

  describe '#to_s' do
    it 'returns tag with all attributes' do
      options = { type: 'PART', uri: 'next_part.ts',
                  byterange_start: 0, byterange_length: 5000 }
      item = described_class.new(options)
      expected = '#EXT-X-PRELOAD-HINT:TYPE=PART,' \
                 'URI="next_part.ts",' \
                 'BYTERANGE-START=0,BYTERANGE-LENGTH=5000'
      expect(item.to_s).to eq(expected)
    end

    it 'returns tag without optional attributes' do
      options = { type: 'PART', uri: 'next_part.ts' }
      item = described_class.new(options)
      expected = '#EXT-X-PRELOAD-HINT:TYPE=PART,URI="next_part.ts"'
      expect(item.to_s).to eq(expected)
    end
  end
end
