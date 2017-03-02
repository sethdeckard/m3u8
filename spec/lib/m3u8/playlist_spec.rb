# frozen_string_literal: true
require 'spec_helper'

describe M3u8::Playlist do
  let(:playlist) { described_class.new }

  describe '#new' do
    it 'initializes with defaults' do
      expect(playlist.version).to be_nil
      expect(playlist.cache).to be_nil
      expect(playlist.target).to eq(10)
      expect(playlist.sequence).to eq(0)
      expect(playlist.discontinuity_sequence).to be_nil
      expect(playlist.type).to be_nil
      expect(playlist.iframes_only).to be false
      expect(playlist.independent_segments).to be false
    end

    it 'initializes from options' do
      options = { version: 7, cache: false, target: 12, sequence: 1,
                  discontinuity_sequence: 2, type: 'VOD',
                  independent_segments: true }
      playlist = described_class.new(options)
      expect(playlist.version).to eq(7)
      expect(playlist.cache).to be false
      expect(playlist.target).to eq(12)
      expect(playlist.sequence).to eq(1)
      expect(playlist.discontinuity_sequence).to eq(2)
      expect(playlist.type).to eq('VOD')
      expect(playlist.iframes_only).to be false
      expect(playlist.independent_segments).to be true
    end

    it 'initializes as master playlist' do
      playlist = described_class.new(master: true)
      expect(playlist.master?).to be true
    end
  end

  describe '.codecs' do
    it 'generates codecs string' do
      options = { profile: 'baseline', level: 3.0, audio_codec: 'aac-lc' }
      codecs = described_class.codecs(options)
      expect(codecs).to eq('avc1.66.30,mp4a.40.2')
    end
  end

  describe '.read' do
    it 'returns new playlist from content' do
      file = File.open('spec/fixtures/master.m3u8')
      playlist = described_class.read(file)
      expect(playlist.master?).to be true
      expect(playlist.items.size).to eq(8)
    end
  end

  describe '#duration' do
    it 'should return the total duration of a playlist' do
      item = M3u8::SegmentItem.new(duration: 10.991, segment: 'test_01.ts')
      playlist.items << item
      item = M3u8::SegmentItem.new(duration: 9.891, segment: 'test_02.ts')
      playlist.items << item
      item = M3u8::SegmentItem.new(duration: 10.556, segment: 'test_03.ts')
      playlist.items << item
      item = M3u8::SegmentItem.new(duration: 8.790, segment: 'test_04.ts')
      playlist.items << item

      expect(playlist.duration.round(3)).to eq(40.228)
    end
  end

  describe '#master?' do
    context 'when playlist is a master playlist' do
      it 'returns true' do
        options = { program_id: '1', uri: 'playlist_url', bandwidth: 6400,
                    audio_codec: 'mp3' }
        item = M3u8::PlaylistItem.new(options)
        playlist.items << item

        expect(playlist.master?).to be true
      end
    end

    context 'when playlist is a media playlist' do
      it 'returns false' do
        item = M3u8::SegmentItem.new(duration: 10.991, segment: 'test_01.ts')
        playlist.items << item
        expect(playlist.master?).to be false
      end
    end

    context 'when playlist is a new playlist' do
      it 'returns false' do
        expect(playlist.master?).to be false
      end
    end

    context 'when a new playlist is set as master' do
      it 'returns true' do
        playlist = described_class.new(master: true)
        expect(playlist.master?).to be true
      end
    end

    context 'when a new playlist is set as not master' do
      it 'returns false' do
        playlist = described_class.new(master: false)
        expect(playlist.master?).to be false
      end
    end
  end

  describe '#to_s' do
    it 'returns master playlist text' do
      options = { program_id: '1', uri: 'playlist_url', bandwidth: 6400,
                  audio_codec: 'mp3' }
      item = M3u8::PlaylistItem.new(options)
      playlist.items << item

      options = { program_id: '2', uri: 'playlist_url', bandwidth: 50_000,
                  width: 1920, height: 1080, profile: 'high', level: 4.1,
                  audio_codec: 'aac-lc' }
      item = M3u8::PlaylistItem.new(options)
      playlist.items << item

      expected = "#EXTM3U\n" +
                 %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34") +
                 ",BANDWIDTH=6400\nplaylist_url\n" \
                 '#EXT-X-STREAM-INF:PROGRAM-ID=2,' +
                 %(RESOLUTION=1920x1080,CODECS="avc1.640029,mp4a.40.2") +
                 ",BANDWIDTH=50000\nplaylist_url\n"
      expect(playlist.to_s).to eq(expected)
    end

    it 'returns media playlist text' do
      options = { duration: 11.344644, segment: '1080-7mbps00000.ts' }
      item =  M3u8::SegmentItem.new(options)
      playlist.items << item

      options = { duration: 11.261233, segment: '1080-7mbps00001.ts' }
      item =  M3u8::SegmentItem.new(options)
      playlist.items << item

      expected = "#EXTM3U\n" \
        "#EXT-X-MEDIA-SEQUENCE:0\n" \
        "#EXT-X-TARGETDURATION:10\n" \
        "#EXTINF:11.344644,\n" \
        "1080-7mbps00000.ts\n" \
        "#EXTINF:11.261233,\n" \
        "1080-7mbps00001.ts\n" \
        "#EXT-X-ENDLIST\n"
      expect(playlist.to_s).to eq(expected)
    end
  end

  describe '#valid?' do
    context 'when playlist is valid' do
      it 'returns true' do
        expect(playlist.valid?).to be true

        options = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
                    bandwidth: 540, uri: 'test.url' }
        item = M3u8::PlaylistItem.new(options)
        playlist.items << item
        expect(playlist.valid?).to be true

        options = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
                    bandwidth: 540, uri: 'test.url' }
        item = M3u8::PlaylistItem.new(options)
        playlist.items << item
        expect(playlist.valid?).to be true
      end
    end

    context 'when playlist is invalid' do
      it 'returns false' do
        options = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
                    bandwidth: 540, uri: 'test.url' }
        item = M3u8::PlaylistItem.new(options)
        playlist.items << item
        expect(playlist.valid?).to be true

        options = { duration: 10.991, segment: 'test.ts' }
        item = M3u8::SegmentItem.new(options)
        playlist.items << item
        expect(playlist.valid?).to be false
      end
    end
  end

  describe '#write' do
    context 'when playlist is valid' do
      it 'returns playlist text' do
        options = { program_id: '1', uri: 'playlist_url', bandwidth: 6400,
                    audio_codec: 'mp3' }
        item = M3u8::PlaylistItem.new(options)
        playlist.items << item

        io = StringIO.new
        playlist.write(io)
        expected = "#EXTM3U\n" +
                   %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34",) +
                   "BANDWIDTH=6400\nplaylist_url\n"
        expect(io.string).to eq(expected)
      end
    end

    context 'when item types are invalid' do
      it 'raises error' do
        options = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
                    bandwidth: 540, uri: 'test.url' }
        item = M3u8::PlaylistItem.new(options)
        playlist.items << item

        options = { duration: 10.991, segment: 'test.ts' }
        item = M3u8::SegmentItem.new(options)
        playlist.items << item

        message = 'Playlist is invalid.'
        io = StringIO.new
        expect { playlist.write(io) }
          .to raise_error(M3u8::PlaylistTypeError, message)
      end
    end
  end
end
