# frozen_string_literal: true

require 'spec_helper'

describe M3u8::GapItem do
  describe '#to_s' do
    it 'returns m3u8 format representation' do
      item = described_class.new
      expect(item.to_s).to eq('#EXT-X-GAP')
    end
  end
end
