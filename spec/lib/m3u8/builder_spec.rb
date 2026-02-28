# frozen_string_literal: true

require 'spec_helper'

describe M3u8::Builder do
  describe '#segment' do
    it 'adds a SegmentItem to the playlist' do
      playlist = M3u8::Playlist.build do
        segment duration: 11.34, segment: '1080-7mbps00000.ts'
      end

      expect(playlist.items.size).to eq(1)
      item = playlist.items.first
      expect(item).to be_a(M3u8::SegmentItem)
      expect(item.duration).to eq(11.34)
      expect(item.segment).to eq('1080-7mbps00000.ts')
    end
  end

  describe 'Playlist.build' do
    it 'returns a Playlist with options' do
      playlist = M3u8::Playlist.build(version: 4, target: 12) do
        segment duration: 11.34, segment: 'test.ts'
      end

      expect(playlist).to be_a(M3u8::Playlist)
      expect(playlist.version).to eq(4)
      expect(playlist.target).to eq(12)
    end

    it 'supports yielded builder form' do
      files = %w[seg1.ts seg2.ts]
      playlist = M3u8::Playlist.build(version: 4) do |b|
        files.each { |f| b.segment duration: 10.0, segment: f }
      end

      expect(playlist.items.size).to eq(2)
      expect(playlist.items[0].segment).to eq('seg1.ts')
      expect(playlist.items[1].segment).to eq('seg2.ts')
    end
  end
end
