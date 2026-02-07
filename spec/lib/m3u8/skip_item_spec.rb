# frozen_string_literal: true

require 'spec_helper'

describe M3u8::SkipItem do
  describe '.new' do
    it 'assigns attributes from options' do
      options = { skipped_segments: 10,
                  recently_removed_dateranges: 'dr1\tdr2' }
      item = described_class.new(options)
      expect(item.skipped_segments).to eq(10)
      expect(item.recently_removed_dateranges).to eq('dr1\tdr2')
    end
  end

  describe '.parse' do
    it 'parses tag with all attributes' do
      tag = '#EXT-X-SKIP:SKIPPED-SEGMENTS=10,' \
            'RECENTLY-REMOVED-DATERANGES="dr1\tdr2"'
      item = described_class.parse(tag)
      expect(item.skipped_segments).to eq(10)
      expect(item.recently_removed_dateranges).to eq('dr1\tdr2')
    end

    it 'parses tag without optional attributes' do
      tag = '#EXT-X-SKIP:SKIPPED-SEGMENTS=5'
      item = described_class.parse(tag)
      expect(item.skipped_segments).to eq(5)
      expect(item.recently_removed_dateranges).to be_nil
    end
  end

  describe '#to_s' do
    it 'returns tag with all attributes' do
      options = { skipped_segments: 10,
                  recently_removed_dateranges: 'dr1\tdr2' }
      item = described_class.new(options)
      expected = '#EXT-X-SKIP:SKIPPED-SEGMENTS=10,' \
                 'RECENTLY-REMOVED-DATERANGES="dr1\tdr2"'
      expect(item.to_s).to eq(expected)
    end

    it 'returns tag with only required attributes' do
      item = described_class.new(skipped_segments: 5)
      expect(item.to_s).to eq('#EXT-X-SKIP:SKIPPED-SEGMENTS=5')
    end
  end
end
