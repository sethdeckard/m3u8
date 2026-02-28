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

  describe '#playlist' do
    it 'adds a PlaylistItem to the playlist' do
      pl = M3u8::Playlist.build do
        playlist bandwidth: 540, uri: 'test.url'
      end

      expect(pl.items.size).to eq(1)
      item = pl.items.first
      expect(item).to be_a(M3u8::PlaylistItem)
      expect(item.bandwidth).to eq(540)
      expect(item.uri).to eq('test.url')
    end
  end

  describe '#media' do
    it 'adds a MediaItem to the playlist' do
      pl = M3u8::Playlist.build do
        media type: 'AUDIO', group_id: 'audio-lo',
              name: 'English', default: true,
              uri: 'eng/prog_index.m3u8'
      end

      expect(pl.items.size).to eq(1)
      item = pl.items.first
      expect(item).to be_a(M3u8::MediaItem)
      expect(item.type).to eq('AUDIO')
      expect(item.group_id).to eq('audio-lo')
      expect(item.name).to eq('English')
    end
  end

  describe '#session_data' do
    it 'adds a SessionDataItem to the playlist' do
      pl = M3u8::Playlist.build do
        session_data data_id: 'com.example.title',
                     value: 'My Video', language: 'en'
      end

      expect(pl.items.size).to eq(1)
      item = pl.items.first
      expect(item).to be_a(M3u8::SessionDataItem)
      expect(item.data_id).to eq('com.example.title')
      expect(item.value).to eq('My Video')
    end
  end

  describe '#session_key' do
    it 'adds a SessionKeyItem to the playlist' do
      pl = M3u8::Playlist.build do
        session_key method: 'AES-128',
                    uri: 'https://example.com/key.bin'
      end

      expect(pl.items.size).to eq(1)
      item = pl.items.first
      expect(item).to be_a(M3u8::SessionKeyItem)
      expect(item.method).to eq('AES-128')
    end
  end

  describe '#content_steering' do
    it 'adds a ContentSteeringItem to the playlist' do
      pl = M3u8::Playlist.build do
        content_steering server_uri: 'https://example.com/s',
                         pathway_id: 'CDN-A'
      end

      expect(pl.items.size).to eq(1)
      item = pl.items.first
      expect(item).to be_a(M3u8::ContentSteeringItem)
      expect(item.server_uri).to eq('https://example.com/s')
      expect(item.pathway_id).to eq('CDN-A')
    end
  end
end
