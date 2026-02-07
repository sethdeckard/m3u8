# frozen_string_literal: true

require 'spec_helper'

describe M3u8::RenditionReportItem do
  describe '.new' do
    it 'assigns attributes from options' do
      options = { uri: '../720p/stream.m3u8', last_msn: 100,
                  last_part: 3 }
      item = described_class.new(options)
      expect(item.uri).to eq('../720p/stream.m3u8')
      expect(item.last_msn).to eq(100)
      expect(item.last_part).to eq(3)
    end
  end

  describe '.parse' do
    it 'parses tag with all attributes' do
      tag = '#EXT-X-RENDITION-REPORT:URI="../720p/stream.m3u8",' \
            'LAST-MSN=100,LAST-PART=3'
      item = described_class.parse(tag)
      expect(item.uri).to eq('../720p/stream.m3u8')
      expect(item.last_msn).to eq(100)
      expect(item.last_part).to eq(3)
    end

    it 'parses tag without optional attributes' do
      tag = '#EXT-X-RENDITION-REPORT:URI="../720p/stream.m3u8",' \
            'LAST-MSN=100'
      item = described_class.parse(tag)
      expect(item.uri).to eq('../720p/stream.m3u8')
      expect(item.last_msn).to eq(100)
      expect(item.last_part).to be_nil
    end
  end

  describe '#to_s' do
    it 'returns tag with all attributes' do
      options = { uri: '../720p/stream.m3u8', last_msn: 100,
                  last_part: 3 }
      item = described_class.new(options)
      expected = '#EXT-X-RENDITION-REPORT:' \
                 'URI="../720p/stream.m3u8",' \
                 'LAST-MSN=100,LAST-PART=3'
      expect(item.to_s).to eq(expected)
    end

    it 'returns tag without optional attributes' do
      options = { uri: '../720p/stream.m3u8', last_msn: 100 }
      item = described_class.new(options)
      expected = '#EXT-X-RENDITION-REPORT:' \
                 'URI="../720p/stream.m3u8",LAST-MSN=100'
      expect(item.to_s).to eq(expected)
    end
  end
end
