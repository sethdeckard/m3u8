# frozen_string_literal: true

require 'spec_helper'

describe M3u8::Writer do
  describe '#write' do
    context 'when playlist is a master playlist' do
      it 'writes playlist to io' do
        playlist = M3u8::Playlist.new
        options = { program_id: '1', uri: 'playlist_url', bandwidth: 6400,
                    audio_codec: 'mp3' }
        item = M3u8::PlaylistItem.new(options)
        playlist.items << item
        options = { program_id: '2', uri: 'playlist_url', bandwidth: 50_000,
                    width: 1920, height: 1080, profile: 'high', level: 4.1,
                    audio_codec: 'aac-lc' }
        item = M3u8::PlaylistItem.new(options)
        playlist.items << item
        options = { data_id: 'com.test.movie.title', value: 'Test',
                    uri: 'http://test', language: 'en' }
        item = M3u8::SessionDataItem.new(options)
        playlist.items << item

        expected = "#EXTM3U\n" +
                   %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34") +
                   ",BANDWIDTH=6400\nplaylist_url\n" \
                   '#EXT-X-STREAM-INF:PROGRAM-ID=2,' +
                   %(RESOLUTION=1920x1080,CODECS="avc1.640029,mp4a.40.2") +
                   ",BANDWIDTH=50000\nplaylist_url\n" +
                   %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",) +
                   %(VALUE="Test",URI="http://test",LANGUAGE="en"\n)

        io = StringIO.open
        writer = described_class.new(io)
        writer.write(playlist)
        expect(io.string).to eq(expected)
      end
    end

    context 'when playlist is a master playlist with single stream' do
      it 'writes playlist to io' do
        options = { program_id: '1', uri: 'playlist_url', bandwidth: 6400,
                    audio_codec: 'mp3' }
        item = M3u8::PlaylistItem.new(options)
        playlist = M3u8::Playlist.new
        playlist.items << item

        expected = "#EXTM3U\n#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS=\"mp4a.40.34\",BANDWIDTH=6400\nplaylist_url\n"

        io = StringIO.open
        writer = described_class.new(io)
        writer.write(playlist)
        expect(io.string).to eq(expected)
      end
    end

    context 'when playlist is a master playlist with header options' do
      it 'writes playlist to io' do
        options = { uri: 'playlist_url', bandwidth: 6400,
                    audio_codec: 'mp3' }
        item = M3u8::PlaylistItem.new(options)
        playlist = M3u8::Playlist.new(version: 6, independent_segments: true)
        playlist.items << item

        expected = "#EXTM3U\n" \
                   "#EXT-X-VERSION:6\n" \
                   "#EXT-X-INDEPENDENT-SEGMENTS\n" +
                   %(#EXT-X-STREAM-INF:CODECS="mp4a.40.34") +
                   ",BANDWIDTH=6400\nplaylist_url\n"

        io = StringIO.open
        writer = described_class.new(io)
        writer.write(playlist)
        expect(io.string).to eq(expected)
      end
    end

    context 'when playlist is a new master playlist' do
      it 'writes playlist to io' do
        io = StringIO.open
        writer = described_class.new(io)
        playlist = M3u8::Playlist.new(master: true)
        writer.write(playlist)
        expect(io.string).to eq("#EXTM3U\n")
      end
    end

    context 'when playlist is a new media playlist' do
      it 'writes playlist to io' do
        io = StringIO.open
        writer = described_class.new(io)
        writer.write(M3u8::Playlist.new)

        expected = "#EXTM3U\n" \
                   "#EXT-X-MEDIA-SEQUENCE:0\n" \
                   "#EXT-X-TARGETDURATION:10\n" \
                   "#EXT-X-ENDLIST\n"
        expect(io.string).to eq(expected)
      end
    end

    context 'when playlist is a media playlist' do
      it 'writes playlist to io' do
        options = { version: 4, cache: false, target: 6.2, sequence: 1,
                    discontinuity_sequence: 10, type: 'EVENT',
                    iframes_only: true }
        playlist = M3u8::Playlist.new(options)
        options = { duration: 11.344644, segment: '1080-7mbps00000.ts' }
        item =  M3u8::SegmentItem.new(options)
        playlist.items << item

        expected = "#EXTM3U\n" \
                   "#EXT-X-PLAYLIST-TYPE:EVENT\n" \
                   "#EXT-X-VERSION:4\n" \
                   "#EXT-X-I-FRAMES-ONLY\n" \
                   "#EXT-X-MEDIA-SEQUENCE:1\n" \
                   "#EXT-X-DISCONTINUITY-SEQUENCE:10\n" \
                   "#EXT-X-ALLOW-CACHE:NO\n" \
                   "#EXT-X-TARGETDURATION:6\n" \
                   "#EXTINF:11.344644,\n" \
                   "1080-7mbps00000.ts\n" \
                   "#EXT-X-ENDLIST\n"

        io = StringIO.open
        writer = described_class.new(io)
        writer.write(playlist)
        expect(io.string).to eq(expected)
      end
    end

    context 'when playlist is media playlist with keys' do
      it 'writes playlist to io' do
        options = { duration: 11.344644, segment: '1080-7mbps00000.ts' }
        item =  M3u8::SegmentItem.new(options)
        playlist = M3u8::Playlist.new(version: 7)
        playlist.items << item

        options = { method: 'AES-128', uri: 'http://test.key',
                    iv: 'D512BBF', key_format: 'identity',
                    key_format_versions: '1/3' }
        item = M3u8::KeyItem.new(options)
        playlist.items << item

        options = { duration: 11.261233, segment: '1080-7mbps00001.ts' }
        item =  M3u8::SegmentItem.new(options)
        playlist.items << item

        expected = "#EXTM3U\n" \
                   "#EXT-X-VERSION:7\n" \
                   "#EXT-X-MEDIA-SEQUENCE:0\n" \
                   "#EXT-X-TARGETDURATION:10\n" \
                   "#EXTINF:11.344644,\n" \
                   "1080-7mbps00000.ts\n" +
                   %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key",) +
                   %(IV=D512BBF,KEYFORMAT="identity",) +
                   %(KEYFORMATVERSIONS="1/3"\n) +
                   "#EXTINF:11.261233,\n" \
                   "1080-7mbps00001.ts\n" \
                   "#EXT-X-ENDLIST\n"

        io = StringIO.open
        writer = described_class.new(io)
        writer.write(playlist)
        expect(io.string).to eq(expected)
      end
    end

    it 'raises error if item types are mixed' do
      playlist = M3u8::Playlist.new
      options = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
                  bandwidth: 540, playlist: 'test.url' }
      item = M3u8::PlaylistItem.new(options)
      playlist.items << item

      options = { duration: 10.991, segment: 'test.ts' }
      item = M3u8::SegmentItem.new(options)
      playlist.items << item

      message = 'Playlist is invalid.'
      io = StringIO.new
      writer = described_class.new(io)
      expect { writer.write(playlist) }
        .to raise_error(M3u8::PlaylistTypeError, message)
    end
  end

  describe '#write_footer' do
    context 'when playlist is a master playlist' do
      it 'does nothing' do
        io = StringIO.open
        writer = described_class.new(io)
        playlist = M3u8::Playlist.new(master: true)
        writer.write_footer(playlist)

        expect(io.string).to be_empty
      end
    end

    context 'when playlist is a media playlist' do
      it 'writes end list tag' do
        io = StringIO.open
        writer = described_class.new(io)
        playlist = M3u8::Playlist.new(master: false)
        writer.write_footer(playlist)

        expect(io.string).to eq("#EXT-X-ENDLIST\n")
      end
    end
  end

  describe '#write_header' do
    context 'when playlist is a master playlist' do
      it 'writes header content only' do
        playlist = M3u8::Playlist.new(version: 6, independent_segments: true)
        options = { uri: 'playlist_url', bandwidth: 6400,
                    audio_codec: 'mp3' }
        item = M3u8::PlaylistItem.new(options)
        playlist.items << item
        expect(playlist.master?).to be true

        expected = "#EXTM3U\n" \
                   "#EXT-X-VERSION:6\n" \
                   "#EXT-X-INDEPENDENT-SEGMENTS\n"

        io = StringIO.open
        writer = described_class.new(io)
        writer.write_header(playlist)
        expect(io.string).to eq(expected)
      end
    end

    context 'when playlist is a media playlist' do
      it 'writes header content only' do
        playlist = M3u8::Playlist.new(version: 7)
        options = { duration: 11.344644, segment: '1080-7mbps00000.ts' }
        item =  M3u8::SegmentItem.new(options)
        playlist.items << item

        io = StringIO.open
        writer = described_class.new(io)
        writer.write_header(playlist)

        expected = "#EXTM3U\n" \
                   "#EXT-X-VERSION:7\n" \
                   "#EXT-X-MEDIA-SEQUENCE:0\n" \
                   "#EXT-X-TARGETDURATION:10\n"

        expect(io.string).to eq(expected)
      end
    end
  end
end
