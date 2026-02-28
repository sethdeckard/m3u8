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

  describe '#key' do
    it 'adds a KeyItem to the playlist' do
      pl = M3u8::Playlist.build do
        key method: 'AES-128',
            uri: 'https://example.com/key.bin'
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::KeyItem)
      expect(item.method).to eq('AES-128')
    end
  end

  describe '#map' do
    it 'adds a MapItem to the playlist' do
      pl = M3u8::Playlist.build do
        map uri: 'init.mp4',
            byterange: { length: 812, start: 0 }
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::MapItem)
      expect(item.uri).to eq('init.mp4')
      expect(item.byterange.length).to eq(812)
    end
  end

  describe '#date_range' do
    it 'adds a DateRangeItem to the playlist' do
      pl = M3u8::Playlist.build do
        date_range id: 'ad-break-1',
                   start_date: '2024-06-01T12:00:00Z',
                   planned_duration: 30.0
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::DateRangeItem)
      expect(item.id).to eq('ad-break-1')
      expect(item.planned_duration).to eq(30.0)
    end
  end

  describe '#discontinuity' do
    it 'adds a DiscontinuityItem to the playlist' do
      pl = M3u8::Playlist.build do
        discontinuity
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::DiscontinuityItem)
    end
  end

  describe '#gap' do
    it 'adds a GapItem to the playlist' do
      pl = M3u8::Playlist.build do
        gap
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::GapItem)
    end
  end

  describe '#time' do
    it 'adds a TimeItem to the playlist' do
      pl = M3u8::Playlist.build do
        time time: '2024-06-01T12:00:00Z'
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::TimeItem)
      expect(item.time).to eq('2024-06-01T12:00:00Z')
    end
  end

  describe '#bitrate' do
    it 'adds a BitrateItem to the playlist' do
      pl = M3u8::Playlist.build do
        bitrate bitrate: 1500
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::BitrateItem)
      expect(item.bitrate).to eq(1500)
    end
  end

  describe '#part' do
    it 'adds a PartItem to the playlist' do
      pl = M3u8::Playlist.build do
        part duration: 0.5, uri: 'seg101.0.mp4',
             independent: true
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::PartItem)
      expect(item.duration).to eq(0.5)
      expect(item.uri).to eq('seg101.0.mp4')
      expect(item.independent).to be true
    end
  end

  describe '#preload_hint' do
    it 'adds a PreloadHintItem to the playlist' do
      pl = M3u8::Playlist.build do
        preload_hint type: 'PART', uri: 'seg101.1.mp4'
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::PreloadHintItem)
      expect(item.type).to eq('PART')
      expect(item.uri).to eq('seg101.1.mp4')
    end
  end

  describe '#rendition_report' do
    it 'adds a RenditionReportItem to the playlist' do
      pl = M3u8::Playlist.build do
        rendition_report uri: '../alt/index.m3u8',
                         last_msn: 101, last_part: 0
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::RenditionReportItem)
      expect(item.uri).to eq('../alt/index.m3u8')
      expect(item.last_msn).to eq(101)
    end
  end

  describe '#skip' do
    it 'adds a SkipItem to the playlist' do
      pl = M3u8::Playlist.build do
        skip skipped_segments: 10
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::SkipItem)
      expect(item.skipped_segments).to eq(10)
    end
  end

  describe '#define' do
    it 'adds a DefineItem to the playlist' do
      pl = M3u8::Playlist.build do
        define name: 'base', value: 'https://example.com'
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::DefineItem)
      expect(item.name).to eq('base')
      expect(item.value).to eq('https://example.com')
    end
  end

  describe '#playback_start' do
    it 'adds a PlaybackStart to the playlist' do
      pl = M3u8::Playlist.build do
        playback_start time_offset: 10.0, precise: true
      end

      item = pl.items.first
      expect(item).to be_a(M3u8::PlaybackStart)
      expect(item.time_offset).to eq(10.0)
      expect(item.precise).to be true
    end
  end

  describe 'integration' do
    it 'builds a complete master playlist' do
      pl = M3u8::Playlist.build(independent_segments: true) do
        playlist bandwidth: 5_042_000,
                 codecs: 'avc1.640028,mp4a.40.2',
                 uri: 'hls/1080/1080.m3u8',
                 width: 1920, height: 1080
        playlist bandwidth: 2_387_000,
                 codecs: 'avc1.4d001f,mp4a.40.2',
                 uri: 'hls/720/720.m3u8',
                 width: 1280, height: 720
      end

      output = pl.to_s
      expect(output).to include('#EXT-X-INDEPENDENT-SEGMENTS')
      expect(output).to include('RESOLUTION=1920x1080')
      expect(output).to include('BANDWIDTH=5042000')
      expect(output).to include('CODECS="avc1.640028,mp4a.40.2"')
      expect(output).to include('hls/1080/1080.m3u8')
      expect(output).to include('RESOLUTION=1280x720')
      expect(output).to include('BANDWIDTH=2387000')
      expect(output).to include('hls/720/720.m3u8')
    end

    it 'builds a complete media playlist' do
      pl = M3u8::Playlist.build(version: 4, target: 12,
                                sequence: 1, cache: false,
                                type: 'VOD') do
        segment duration: 11.34, segment: '00000.ts'
        discontinuity
        segment duration: 11.26, segment: '00001.ts'
      end

      expected = "#EXTM3U\n" \
                 "#EXT-X-PLAYLIST-TYPE:VOD\n" \
                 "#EXT-X-VERSION:4\n" \
                 "#EXT-X-MEDIA-SEQUENCE:1\n" \
                 "#EXT-X-ALLOW-CACHE:NO\n" \
                 "#EXT-X-TARGETDURATION:12\n" \
                 "#EXTINF:11.34,\n" \
                 "00000.ts\n" \
                 "#EXT-X-DISCONTINUITY\n" \
                 "#EXTINF:11.26,\n" \
                 "00001.ts\n" \
                 "#EXT-X-ENDLIST\n"
      expect(pl.to_s).to eq(expected)
    end

    it 'builds an LL-HLS playlist' do
      sc = M3u8::ServerControlItem.new(
        can_skip_until: 24.0, part_hold_back: 1.0,
        can_block_reload: true
      )
      pi = M3u8::PartInfItem.new(part_target: 0.5)

      pl = M3u8::Playlist.build(
        version: 9, target: 4, sequence: 100,
        server_control: sc, part_inf: pi, live: true
      ) do
        map uri: 'init.mp4'
        segment duration: 4.0, segment: 'seg100.mp4'
        part duration: 0.5, uri: 'seg101.0.mp4',
             independent: true
        preload_hint type: 'PART', uri: 'seg101.1.mp4'
        rendition_report uri: '../alt/index.m3u8',
                         last_msn: 101, last_part: 0
      end

      output = pl.to_s
      expect(output).to include('#EXT-X-SERVER-CONTROL:')
      expect(output).to include('#EXT-X-PART-INF:')
      expect(output).to include('#EXT-X-MAP:URI="init.mp4"')
      expect(output).to include('#EXTINF:4.0,')
      expect(output).to include('seg100.mp4')
      expect(output).to include('#EXT-X-PART:DURATION=0.5')
      expect(output).to include('#EXT-X-PRELOAD-HINT:')
      expect(output).to include('#EXT-X-RENDITION-REPORT:')
      expect(output).not_to include('#EXT-X-ENDLIST')
    end
  end
end
