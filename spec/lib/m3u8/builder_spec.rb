# frozen_string_literal: true

require 'spec_helper'

describe M3u8::Builder do
  shared_examples 'a builder method' do |method, klass, params, checks|
    it "adds a #{klass} to the playlist" do
      pl = M3u8::Playlist.build { send(method, **params) }

      item = pl.items.first
      expect(item).to be_a(klass)
      checks.each do |attr, value|
        expect(item.public_send(attr)).to eq(value)
      end
    end
  end

  shared_examples 'a zero-arg builder method' do |method, klass|
    it "adds a #{klass} to the playlist" do
      pl = M3u8::Playlist.build { send(method) }
      expect(pl.items.first).to be_a(klass)
    end
  end

  describe '#segment' do
    include_examples 'a builder method',
                     :segment, M3u8::SegmentItem,
                     { duration: 11.34,
                       segment: '1080-7mbps00000.ts' },
                     { duration: 11.34,
                       segment: '1080-7mbps00000.ts' }
  end

  describe '#playlist' do
    include_examples 'a builder method',
                     :playlist, M3u8::PlaylistItem,
                     { bandwidth: 540, uri: 'test.url' },
                     { bandwidth: 540, uri: 'test.url' }
  end

  describe '#media' do
    include_examples 'a builder method',
                     :media, M3u8::MediaItem,
                     { type: 'AUDIO', group_id: 'audio-lo',
                       name: 'English', default: true,
                       uri: 'eng/prog_index.m3u8' },
                     { type: 'AUDIO', group_id: 'audio-lo',
                       name: 'English' }
  end

  describe '#session_data' do
    include_examples 'a builder method',
                     :session_data, M3u8::SessionDataItem,
                     { data_id: 'com.example.title',
                       value: 'My Video', language: 'en' },
                     { data_id: 'com.example.title',
                       value: 'My Video' }
  end

  describe '#session_key' do
    include_examples 'a builder method',
                     :session_key, M3u8::SessionKeyItem,
                     { method: 'AES-128',
                       uri: 'https://example.com/key.bin' },
                     { method: 'AES-128' }
  end

  describe '#content_steering' do
    include_examples 'a builder method',
                     :content_steering,
                     M3u8::ContentSteeringItem,
                     { server_uri: 'https://example.com/s',
                       pathway_id: 'CDN-A' },
                     { server_uri: 'https://example.com/s',
                       pathway_id: 'CDN-A' }
  end

  describe '#key' do
    include_examples 'a builder method',
                     :key, M3u8::KeyItem,
                     { method: 'AES-128',
                       uri: 'https://example.com/key.bin' },
                     { method: 'AES-128' }
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
    include_examples 'a builder method',
                     :date_range, M3u8::DateRangeItem,
                     { id: 'ad-break-1',
                       start_date: '2024-06-01T12:00:00Z',
                       planned_duration: 30.0 },
                     { id: 'ad-break-1',
                       planned_duration: 30.0 }
  end

  describe '#discontinuity' do
    include_examples 'a zero-arg builder method',
                     :discontinuity, M3u8::DiscontinuityItem
  end

  describe '#gap' do
    include_examples 'a zero-arg builder method',
                     :gap, M3u8::GapItem
  end

  describe '#time' do
    include_examples 'a builder method',
                     :time, M3u8::TimeItem,
                     { time: '2024-06-01T12:00:00Z' },
                     { time: '2024-06-01T12:00:00Z' }
  end

  describe '#bitrate' do
    include_examples 'a builder method',
                     :bitrate, M3u8::BitrateItem,
                     { bitrate: 1500 },
                     { bitrate: 1500 }
  end

  describe '#part' do
    include_examples 'a builder method',
                     :part, M3u8::PartItem,
                     { duration: 0.5, uri: 'seg101.0.mp4',
                       independent: true },
                     { duration: 0.5, uri: 'seg101.0.mp4' }
  end

  describe '#preload_hint' do
    include_examples 'a builder method',
                     :preload_hint, M3u8::PreloadHintItem,
                     { type: 'PART', uri: 'seg101.1.mp4' },
                     { type: 'PART', uri: 'seg101.1.mp4' }
  end

  describe '#rendition_report' do
    include_examples 'a builder method',
                     :rendition_report,
                     M3u8::RenditionReportItem,
                     { uri: '../alt/index.m3u8',
                       last_msn: 101, last_part: 0 },
                     { uri: '../alt/index.m3u8',
                       last_msn: 101 }
  end

  describe '#skip' do
    include_examples 'a builder method',
                     :skip, M3u8::SkipItem,
                     { skipped_segments: 10 },
                     { skipped_segments: 10 }
  end

  describe '#define' do
    include_examples 'a builder method',
                     :define, M3u8::DefineItem,
                     { name: 'base',
                       value: 'https://example.com' },
                     { name: 'base',
                       value: 'https://example.com' }
  end

  describe '#playback_start' do
    include_examples 'a builder method',
                     :playback_start, M3u8::PlaybackStart,
                     { time_offset: 10.0, precise: true },
                     { time_offset: 10.0 }
  end

  describe 'Playlist.build' do
    it 'returns a Playlist with options' do
      playlist = M3u8::Playlist.build(version: 4,
                                      target: 12) do
        segment duration: 11.34, segment: 'test.ts'
      end

      expect(playlist).to be_a(M3u8::Playlist)
      expect(playlist.version).to eq(4)
      expect(playlist.target).to eq(12)
    end

    it 'supports yielded builder form' do
      files = %w[seg1.ts seg2.ts]
      playlist = M3u8::Playlist.build(version: 4) do |b|
        files.each do |f|
          b.segment duration: 10.0, segment: f
        end
      end

      expect(playlist.items.size).to eq(2)
      expect(playlist.items[0].segment).to eq('seg1.ts')
      expect(playlist.items[1].segment).to eq('seg2.ts')
    end
  end

  describe 'integration' do
    it 'builds a complete master playlist' do
      pl = M3u8::Playlist.build(
        independent_segments: true
      ) do
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
      expect(output).to include(
        '#EXT-X-INDEPENDENT-SEGMENTS'
      )
      expect(output).to include('RESOLUTION=1920x1080')
      expect(output).to include('BANDWIDTH=5042000')
      expect(output).to include(
        'CODECS="avc1.640028,mp4a.40.2"'
      )
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
      expect(output).to include(
        '#EXT-X-MAP:URI="init.mp4"'
      )
      expect(output).to include('#EXTINF:4.0,')
      expect(output).to include('seg100.mp4')
      expect(output).to include(
        '#EXT-X-PART:DURATION=0.5'
      )
      expect(output).to include('#EXT-X-PRELOAD-HINT:')
      expect(output).to include(
        '#EXT-X-RENDITION-REPORT:'
      )
      expect(output).not_to include('#EXT-X-ENDLIST')
    end
  end
end
