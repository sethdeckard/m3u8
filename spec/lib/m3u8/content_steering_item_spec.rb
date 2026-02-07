# frozen_string_literal: true

require 'spec_helper'

describe M3u8::ContentSteeringItem do
  describe '.new' do
    it 'assigns attributes from options' do
      item = described_class.new(
        server_uri: 'https://example.com/steering',
        pathway_id: 'CDN-A'
      )
      expect(item.server_uri).to eq('https://example.com/steering')
      expect(item.pathway_id).to eq('CDN-A')
    end
  end

  describe '.parse' do
    it 'parses tag with all attributes' do
      tag = '#EXT-X-CONTENT-STEERING:SERVER-URI=' \
            '"https://example.com/steering",PATHWAY-ID="CDN-A"'
      item = described_class.parse(tag)
      expect(item.server_uri).to eq('https://example.com/steering')
      expect(item.pathway_id).to eq('CDN-A')
    end

    it 'parses tag without optional pathway id' do
      tag = '#EXT-X-CONTENT-STEERING:' \
            'SERVER-URI="https://example.com/steering"'
      item = described_class.parse(tag)
      expect(item.server_uri).to eq('https://example.com/steering')
      expect(item.pathway_id).to be_nil
    end
  end

  describe '#to_s' do
    it 'returns tag with all attributes' do
      item = described_class.new(
        server_uri: 'https://example.com/steering',
        pathway_id: 'CDN-A'
      )
      expected = '#EXT-X-CONTENT-STEERING:' \
                 'SERVER-URI="https://example.com/steering",' \
                 'PATHWAY-ID="CDN-A"'
      expect(item.to_s).to eq(expected)
    end

    it 'returns tag without optional pathway id' do
      item = described_class.new(
        server_uri: 'https://example.com/steering'
      )
      expected = '#EXT-X-CONTENT-STEERING:' \
                 'SERVER-URI="https://example.com/steering"'
      expect(item.to_s).to eq(expected)
    end
  end
end
