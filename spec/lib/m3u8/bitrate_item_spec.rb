# frozen_string_literal: true

require 'spec_helper'

describe M3u8::BitrateItem do
  describe '.new' do
    it 'assigns attributes from options' do
      item = described_class.new(bitrate: 128)
      expect(item.bitrate).to eq(128)
    end
  end

  describe '.parse' do
    it 'returns instance from parsed tag' do
      item = described_class.parse('#EXT-X-BITRATE:128')
      expect(item.bitrate).to eq(128)
    end
  end

  describe '#to_s' do
    it 'returns m3u8 format representation' do
      item = described_class.new(bitrate: 128)
      expect(item.to_s).to eq('#EXT-X-BITRATE:128')
    end
  end
end
