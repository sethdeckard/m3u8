require 'spec_helper'

describe M3u8::PlaybackStart do
  describe '#intialize' do
    it 'assigns attributes' do
      start = described_class.new(time_offset: -12.9, precise: true)
      expect(start.time_offset).to eq(-12.9)
      expect(start.precise).to be true
    end
  end

  describe '#parse' do
    it 'parses tag with all attributes' do
      start = described_class.new
      tag = '#EXT-X-START:TIME-OFFSET=20.0,PRECISE=YES'
      start.parse(tag)

      expect(start.time_offset).to eq(20.0)
      expect(start.precise).to be true
    end

    it 'parses tag without optional attributes' do
      start = described_class.new
      tag = '#EXT-X-START:TIME-OFFSET=-12.9'
      start.parse(tag)

      expect(start.time_offset).to eq(-12.9)
      expect(start.precise).to be_nil
    end
  end
end
