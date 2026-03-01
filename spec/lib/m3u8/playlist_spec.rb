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

    it 'generates HEVC codecs string' do
      options = { profile: 'hevc-main', level: 4.0, audio_codec: 'ac-3' }
      codecs = described_class.codecs(options)
      expect(codecs).to eq('hvc1.1.6.L120.B0,ac-3')
    end

    it 'generates AV1 codecs string' do
      options = { profile: 'av1-main', level: 5.0, audio_codec: 'opus' }
      codecs = described_class.codecs(options)
      expect(codecs).to eq('av01.0.12M.08,Opus')
    end
  end

  describe '.read' do
    it 'returns new playlist from content' do
      playlist = described_class.read(
        File.read('spec/fixtures/master.m3u8')
      )
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

  describe '#live?' do
    context 'when playlist is a master playlist' do
      it 'returns false' do
        options = { program_id: '1', uri: 'playlist_url', bandwidth: 6400,
                    audio_codec: 'mp3' }
        item = M3u8::PlaylistItem.new(options)
        playlist.items << item

        expect(playlist.live).to be false
      end
    end

    context 'when playlist is a media playlist and set as live' do
      it 'returns true' do
        playlist = described_class.new(live: true)
        item = M3u8::SegmentItem.new(duration: 10.991, segment: 'test_01.ts')
        playlist.items << item
        expect(playlist.live?).to be true
      end
    end

    context 'when a new playlist is set as not live' do
      it 'returns false' do
        playlist = described_class.new(live: false)
        expect(playlist.live).to be false
      end
    end

    context 'when playlist is a new playlist' do
      it 'returns false' do
        expect(playlist.live?).to be false
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
      playlist = described_class.new(target: 12)
      options = { duration: 11.344644, segment: '1080-7mbps00000.ts' }
      item =  M3u8::SegmentItem.new(options)
      playlist.items << item

      options = { duration: 11.261233, segment: '1080-7mbps00001.ts' }
      item =  M3u8::SegmentItem.new(options)
      playlist.items << item

      expected = "#EXTM3U\n" \
                 "#EXT-X-MEDIA-SEQUENCE:0\n" \
                 "#EXT-X-TARGETDURATION:12\n" \
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

  describe '#errors' do
    context 'when playlist is empty' do
      it 'returns no errors' do
        expect(playlist.errors).to be_empty
      end
    end

    context 'when playlist has only master items' do
      it 'returns no errors' do
        playlist.items << M3u8::PlaylistItem.new(
          bandwidth: 540, uri: 'test.url'
        )
        expect(playlist.errors).to be_empty
      end
    end

    context 'when playlist has only media items' do
      it 'returns no errors' do
        playlist.items << M3u8::SegmentItem.new(
          duration: 10.0, segment: 'test.ts'
        )
        expect(playlist.errors).to be_empty
      end
    end

    context 'when segment duration exceeds target duration' do
      it 'returns target duration error' do
        playlist = described_class.new(target: 10)
        playlist.items << M3u8::SegmentItem.new(
          duration: 12.1, segment: 'test.ts'
        )
        expect(playlist.errors).to include(
          'Target duration 10 is less than segment duration of 12'
        )
      end
    end

    context 'when segment duration rounds to target' do
      it 'returns no errors' do
        playlist = described_class.new(target: 11)
        playlist.items << M3u8::SegmentItem.new(
          duration: 10.5, segment: 'test.ts'
        )
        expect(playlist.errors).to be_empty
      end
    end

    context 'when playlist is master' do
      it 'skips target duration check' do
        playlist = described_class.new(master: true)
        expect(playlist.errors).to be_empty
      end
    end

    context 'when segment has no URI' do
      it 'returns missing segment error' do
        playlist.items << M3u8::SegmentItem.new(duration: 10.0)
        expect(playlist.errors).to include(
          'Segment item requires a segment URI'
        )
      end
    end

    context 'when segment has negative duration' do
      it 'returns negative duration error' do
        playlist.items << M3u8::SegmentItem.new(
          duration: -1.0, segment: 'test.ts'
        )
        expect(playlist.errors).to include(
          'Segment item has negative duration'
        )
      end
    end

    context 'when segment has zero duration' do
      it 'returns no errors' do
        playlist.items << M3u8::SegmentItem.new(
          duration: 0.0, segment: 'test.ts'
        )
        expect(playlist.errors).to be_empty
      end
    end

    context 'when multiple segments are invalid' do
      it 'accumulates errors' do
        playlist.items << M3u8::SegmentItem.new(duration: 10.0)
        playlist.items << M3u8::SegmentItem.new(
          duration: -1.0, segment: 'test.ts'
        )
        errors = playlist.errors
        expect(errors).to include(
          'Segment item requires a segment URI'
        )
        expect(errors).to include(
          'Segment item has negative duration'
        )
      end
    end

    context 'when playlist item has no bandwidth' do
      it 'returns missing bandwidth error' do
        playlist.items << M3u8::PlaylistItem.new(uri: 'test.url')
        expect(playlist.errors).to include(
          'Playlist item requires a bandwidth'
        )
      end
    end

    context 'when playlist item has no URI and is not iframe' do
      it 'returns missing URI error' do
        playlist.items << M3u8::PlaylistItem.new(bandwidth: 540)
        expect(playlist.errors).to include(
          'Playlist item requires a URI'
        )
      end
    end

    context 'when playlist item has zero bandwidth' do
      it 'returns missing bandwidth error' do
        playlist.items << M3u8::PlaylistItem.new(
          bandwidth: 0, uri: 'test.url'
        )
        expect(playlist.errors).to include(
          'Playlist item requires a bandwidth'
        )
      end
    end

    context 'when iframe playlist item has no URI' do
      it 'returns missing URI error' do
        playlist.items << M3u8::PlaylistItem.new(
          bandwidth: 540, iframe: true
        )
        expect(playlist.errors).to include(
          'Playlist item requires a URI'
        )
      end
    end

    context 'when media item is missing type' do
      it 'returns missing type error' do
        playlist.items << M3u8::PlaylistItem.new(
          bandwidth: 540, uri: 'test.url'
        )
        playlist.items << M3u8::MediaItem.new(
          group_id: 'audio', name: 'English'
        )
        expect(playlist.errors).to include(
          'Media item requires a type'
        )
      end
    end

    context 'when media item is missing group_id' do
      it 'returns missing group_id error' do
        playlist.items << M3u8::PlaylistItem.new(
          bandwidth: 540, uri: 'test.url'
        )
        playlist.items << M3u8::MediaItem.new(
          type: 'AUDIO', name: 'English'
        )
        expect(playlist.errors).to include(
          'Media item requires a group ID'
        )
      end
    end

    context 'when media item is missing name' do
      it 'returns missing name error' do
        playlist.items << M3u8::PlaylistItem.new(
          bandwidth: 540, uri: 'test.url'
        )
        playlist.items << M3u8::MediaItem.new(
          type: 'AUDIO', group_id: 'audio'
        )
        expect(playlist.errors).to include(
          'Media item requires a name'
        )
      end
    end

    context 'when key item has method but no URI' do
      it 'returns missing URI error' do
        playlist.items << M3u8::SegmentItem.new(
          duration: 10.0, segment: 'test.ts'
        )
        playlist.items << M3u8::KeyItem.new(method: 'AES-128')
        expect(playlist.errors).to include(
          'Key item requires a URI when method is not NONE'
        )
      end
    end

    context 'when key item method is NONE' do
      it 'returns no errors' do
        playlist.items << M3u8::SegmentItem.new(
          duration: 10.0, segment: 'test.ts'
        )
        playlist.items << M3u8::KeyItem.new(method: 'NONE')
        expect(playlist.errors).to be_empty
      end
    end

    context 'when session key item has method but no URI' do
      it 'returns missing URI error' do
        playlist.items << M3u8::PlaylistItem.new(
          bandwidth: 540, uri: 'test.url'
        )
        playlist.items << M3u8::SessionKeyItem.new(
          method: 'AES-128'
        )
        expect(playlist.errors).to include(
          'Session key item requires a URI when method is not NONE'
        )
      end
    end

    context 'when playlist has mixed items' do
      it 'returns mixed items error' do
        playlist.items << M3u8::PlaylistItem.new(
          bandwidth: 540, uri: 'test.url'
        )
        playlist.items << M3u8::SegmentItem.new(
          duration: 10.0, segment: 'test.ts'
        )
        expect(playlist.errors).to include(
          'Playlist contains both master and media items'
        )
      end
    end
  end

  describe '#segments' do
    it 'returns only segment items' do
      playlist = described_class.read(
        File.read('spec/fixtures/playlist.m3u8')
      )
      expect(playlist.segments).to all be_a(M3u8::SegmentItem)
      expect(playlist.segments.size).to eq(138)
    end
  end

  describe '#playlists' do
    it 'returns only playlist items' do
      playlist = described_class.read(
        File.read('spec/fixtures/master.m3u8')
      )
      expect(playlist.playlists).to all be_a(M3u8::PlaylistItem)
      expect(playlist.playlists.size).to eq(6)
    end
  end

  describe '#media_items' do
    it 'returns only media items' do
      playlist = described_class.read(
        File.read('spec/fixtures/variant_audio.m3u8')
      )
      expect(playlist.media_items).to all be_a(M3u8::MediaItem)
      expect(playlist.media_items.size).to eq(6)
    end
  end

  describe '#keys' do
    it 'returns only key items' do
      playlist = described_class.read(
        File.read('spec/fixtures/encrypted.m3u8')
      )
      expect(playlist.keys).to all be_a(M3u8::KeyItem)
      expect(playlist.keys.size).to eq(2)
    end
  end

  describe '#maps' do
    it 'returns only map items' do
      playlist = described_class.read(
        File.read('spec/fixtures/map_playlist.m3u8')
      )
      expect(playlist.maps).to all be_a(M3u8::MapItem)
      expect(playlist.maps.size).to eq(1)
    end
  end

  describe '#date_ranges' do
    it 'returns only date range items' do
      playlist = described_class.read(
        File.read('spec/fixtures/daterange_playlist.m3u8')
      )
      expect(playlist.date_ranges)
        .to all be_a(M3u8::DateRangeItem)
      expect(playlist.date_ranges.size).to eq(3)
    end
  end

  describe '#parts' do
    it 'returns only part items' do
      playlist = described_class.read(
        File.read('spec/fixtures/ll_hls_playlist.m3u8')
      )
      expect(playlist.parts).to all be_a(M3u8::PartItem)
      expect(playlist.parts.size).to eq(5)
    end
  end

  describe '#session_data' do
    it 'returns only session data items' do
      playlist = described_class.read(
        File.read('spec/fixtures/session_data.m3u8')
      )
      expect(playlist.session_data)
        .to all be_a(M3u8::SessionDataItem)
      expect(playlist.session_data.size).to eq(3)
    end
  end

  describe '#session_keys' do
    it 'returns only session key items' do
      playlist = described_class.read(
        File.read('spec/fixtures/master.m3u8')
      )
      expect(playlist.session_keys)
        .to all be_a(M3u8::SessionKeyItem)
      expect(playlist.session_keys.size).to eq(1)
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
        expected = "#EXTM3U\n#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS=\"mp4a.40.34\",BANDWIDTH=6400\nplaylist_url\n"
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
