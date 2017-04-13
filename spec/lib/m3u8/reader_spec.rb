# frozen_string_literal: true
require 'spec_helper'

describe M3u8::Reader do
  let(:reader) { described_class.new }

  describe '#read' do
    it 'parses master playlist' do
      file = File.open('spec/fixtures/master.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)
      expect(playlist.master?).to be true
      expect(playlist.discontinuity_sequence).to be_nil
      expect(playlist.independent_segments).to be true

      item = playlist.items[0]
      expect(item).to be_a(M3u8::SessionKeyItem)
      expect(item.method).to eq('AES-128')
      expect(item.uri).to eq('https://priv.example.com/key.php?r=52')

      item = playlist.items[1]
      expect(item).to be_a(M3u8::PlaybackStart)
      expect(item.time_offset).to eq(20.2)

      item = playlist.items[2]
      expect(item).to be_a(M3u8::PlaylistItem)
      expect(item.uri).to eq('hls/1080-7mbps/1080-7mbps.m3u8')
      expect(item.program_id).to eq('1')
      expect(item.width).to eq(1920)
      expect(item.height).to eq(1080)
      expect(item.resolution).to eq('1920x1080')
      expect(item.codecs).to eq('avc1.640028,mp4a.40.2')
      expect(item.bandwidth).to eq(5_042_000)
      expect(item.iframe).to be false
      expect(item.average_bandwidth).to be_nil

      item = playlist.items[7]
      expect(item).to be_a(M3u8::PlaylistItem)
      expect(item.uri).to eq('hls/64k/64k.m3u8')
      expect(item.program_id).to eq('1')
      expect(item.width).to be_nil
      expect(item.height).to be_nil
      expect(item.resolution).to be_nil
      expect(item.codecs).to eq('mp4a.40.2')
      expect(item.bandwidth).to eq(6400)
      expect(item.iframe).to be false
      expect(item.average_bandwidth).to be_nil

      expect(playlist.items.size).to eq(8)

      item = playlist.items.last
      expect(item.resolution).to be_nil
    end

    it 'parses master playlist with I-Frames' do
      file = File.open('spec/fixtures/master_iframes.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)
      expect(playlist.master?).to be true

      expect(playlist.items.size).to eq(7)

      item = playlist.items[1]
      expect(item).to be_a(M3u8::PlaylistItem)
      expect(item.bandwidth).to eq(86_000)
      expect(item.iframe).to be true
      expect(item.uri).to eq('low/iframe.m3u8')
    end

    it 'parses media playlist' do
      file = File.open('spec/fixtures/playlist.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)
      expect(playlist.master?).to be false
      expect(playlist.version).to eq(4)
      expect(playlist.sequence).to eq(1)
      expect(playlist.discontinuity_sequence).to eq(8)
      expect(playlist.cache).to be false
      expect(playlist.target).to eq(12)
      expect(playlist.type).to eq('VOD')

      item = playlist.items[0]
      expect(item).to be_a(M3u8::SegmentItem)
      expect(item.duration).to eq(11.344644)
      expect(item.comment).to be_nil

      item = playlist.items[4]
      expect(item).to be_a(M3u8::TimeItem)
      expect(item.time).to eq(Time.iso8601('2010-02-19T14:54:23Z'))

      expect(playlist.items.size).to eq(140)
    end

    it 'parses I-Frame playlist' do
      file = File.open('spec/fixtures/iframes.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)

      expect(playlist.iframes_only).to be true
      expect(playlist.items.size).to eq(3)

      item = playlist.items[0]
      expect(item).to be_a(M3u8::SegmentItem)
      expect(item.duration).to eq(4.12)
      expect(item.byterange.length).to eq(9400)
      expect(item.byterange.start).to eq(376)
      expect(item.segment).to eq('segment1.ts')

      item = playlist.items[1]
      expect(item.byterange.length).to eq(7144)
      expect(item.byterange.start).to be_nil
    end

    it 'parses segment playlist with comments' do
      file = File.open('spec/fixtures/playlist_with_comments.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)
      expect(playlist.master?).to be false
      expect(playlist.version).to eq(4)
      expect(playlist.sequence).to eq(1)
      expect(playlist.cache).to be false
      expect(playlist.target).to eq(12)
      expect(playlist.type).to eq('VOD')

      item = playlist.items[0]
      expect(item).to be_a(M3u8::SegmentItem)
      expect(item.duration).to eq(11.344644)
      expect(item.comment).to eq('anything')

      item = playlist.items[1]
      expect(item).to be_a(M3u8::DiscontinuityItem)

      expect(playlist.items.size).to eq(139)
    end

    it 'parses variant playlist with audio options and groups' do
      file = File.open('spec/fixtures/variant_audio.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)

      expect(playlist.master?).to be true
      expect(playlist.items.size).to eq(10)

      item = playlist.items[0]
      expect(item).to be_a(M3u8::MediaItem)
      expect(item.type).to eq('AUDIO')
      expect(item.group_id).to eq('audio-lo')
      expect(item.language).to eq('eng')
      expect(item.assoc_language).to eq('spoken')
      expect(item.name).to eq('English')
      expect(item.autoselect).to be true
      expect(item.default).to be true
      expect(item.uri).to eq('englo/prog_index.m3u8')
      expect(item.forced).to be true
    end

    it 'parses variant playlist with camera angles' do
      file = File.open('spec/fixtures/variant_angles.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)

      expect(playlist.master?).to be true
      expect(playlist.items.size).to eq(11)

      item = playlist.items[1]
      expect(item).to be_a(M3u8::MediaItem)
      expect(item.type).to eq('VIDEO')
      expect(item.group_id).to eq('200kbs')
      expect(item.language).to be_nil
      expect(item.name).to eq('Angle2')
      expect(item.autoselect).to be true
      expect(item.default).to be false
      expect(item.uri).to eq('Angle2/200kbs/prog_index.m3u8')

      item = playlist.items[9]
      expect(item.average_bandwidth).to eq(300_001)
      expect(item.audio).to eq('aac')
      expect(item.video).to eq('200kbs')
      expect(item.closed_captions).to eq('captions')
      expect(item.subtitles).to eq('subs')
    end

    it 'processes multiple reads as separate playlists' do
      file = File.open('spec/fixtures/master.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)

      expect(playlist.items.size).to eq(8)

      file = File.open('spec/fixtures/master.m3u8')
      playlist = reader.read(file)

      expect(playlist.items.size).to eq(8)
    end

    it 'parses playlist with session data' do
      file = File.open('spec/fixtures/session_data.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)

      expect(playlist.items.size).to eq(3)

      item = playlist.items[0]
      expect(item).to be_a(M3u8::SessionDataItem)
      expect(item.data_id).to eq('com.example.lyrics')
      expect(item.uri).to eq('lyrics.json')
    end

    it 'parses encrypted playlist' do
      file = File.open('spec/fixtures/encrypted.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)

      expect(playlist.items.size).to eq(6)

      item = playlist.items[0]
      expect(item).to be_a(M3u8::KeyItem)
      expect(item.method).to eq('AES-128')
      expect(item.uri).to eq('https://priv.example.com/key.php?r=52')
    end

    it 'parses map (media intialization section) playlists' do
      file = File.open('spec/fixtures/map_playlist.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)

      expect(playlist.items.size).to eq(1)

      item = playlist.items[0]
      expect(item).to be_a(M3u8::MapItem)
      expect(item.uri).to eq('frelo/prog_index.m3u8')
      expect(item.byterange.length).to eq(4500)
      expect(item.byterange.start).to eq(600)
    end

    it 'reads segment with timestamp' do
      file = File.open('spec/fixtures/timestamp_playlist.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)
      expect(playlist.items.count).to eq(6)

      item_date_time = playlist.items.first.program_date_time
      expect(item_date_time).to be_a(M3u8::TimeItem)
      expect(item_date_time.time).to eq(Time.iso8601('2016-04-11T15:24:31Z'))
    end

    it 'parses playlist with daterange' do
      file = File.open('spec/fixtures/date_range_scte35.m3u8')
      reader = M3u8::Reader.new
      playlist = reader.read(file)
      expect(playlist.items.count).to eq(5)

      item = playlist.items[0]
      expect(item).to be_a(M3u8::DateRangeItem)

      item = playlist.items[4]
      expect(item).to be_a(M3u8::DateRangeItem)
    end

    context 'when playlist source is invalid' do
      it 'raises error with message' do
        message = 'Playlist must start with a #EXTM3U tag, line read ' \
          'contained the value: /path/to/file'
        expect { reader.read('/path/to/file') }
          .to raise_error(M3u8::InvalidPlaylistError, message)
      end
    end
  end
end
