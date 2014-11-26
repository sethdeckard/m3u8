require 'spec_helper'

describe M3u8::Writer do
  it 'should render master playlist' do
    playlist = M3u8::Playlist.new
    playlist.add_playlist '1', 'playlist_url', 6400, audio: 'mp3'

    output = "#EXTM3U\n" +
             %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34") +
             ",BANDWIDTH=6400\nplaylist_url\n"

    io = StringIO.open
    writer = M3u8::Writer.new io
    writer.write playlist
    expect(io.string).to eq output

    playlist = M3u8::Playlist.new
    options = { width: 1920, height: 1080, profile: 'high', level: 4.1,
                audio: 'aac-lc' }
    playlist.add_playlist '2', 'playlist_url', 50_000, options

    output = "#EXTM3U\n" \
             '#EXT-X-STREAM-INF:PROGRAM-ID=2,RESOLUTION=1920x1080,' +
             %(CODECS="avc1.640028,mp4a.40.2",BANDWIDTH=50000\n) +
             "playlist_url\n"

    io = StringIO.open
    writer = M3u8::Writer.new io
    writer.write playlist
    expect(io.string).to eq output

    playlist = M3u8::Playlist.new
    playlist.add_playlist '1', 'playlist_url', 6400, audio: 'mp3'
    options = { width: 1920, height: 1080, profile: 'high', level: 4.1,
                audio: 'aac-lc' }
    playlist.add_playlist '2', 'playlist_url', 50_000, options

    output = "#EXTM3U\n" +
             %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34") +
             ",BANDWIDTH=6400\nplaylist_url\n#EXT-X-STREAM-INF:PROGRAM-ID=2," +
             %(RESOLUTION=1920x1080,CODECS="avc1.640028,mp4a.40.2") +
             ",BANDWIDTH=50000\nplaylist_url\n"

    io = StringIO.open
    writer = M3u8::Writer.new io
    writer.write playlist
    expect(io.string).to eq output
  end

  it 'should render playlist' do
    playlist = M3u8::Playlist.new
    playlist.add_segment 11.344644, '1080-7mbps00000.ts'

    output = "#EXTM3U\n" \
      "#EXT-X-VERSION:3\n" \
      "#EXT-X-MEDIA-SEQUENCE:0\n" \
      "#EXT-X-ALLOW-CACHE:YES\n" \
      "#EXT-X-TARGETDURATION:10\n" \
      "#EXTINF:11.344644,\n" \
      "1080-7mbps00000.ts\n" \
      "#EXT-X-ENDLIST\n"

    io = StringIO.open
    writer = M3u8::Writer.new io
    writer.write playlist
    expect(io.string).to eq output

    playlist.add_segment 11.261233, '1080-7mbps00001.ts'

    output = "#EXTM3U\n" \
      "#EXT-X-VERSION:3\n" \
      "#EXT-X-MEDIA-SEQUENCE:0\n" \
      "#EXT-X-ALLOW-CACHE:YES\n" \
      "#EXT-X-TARGETDURATION:10\n" \
      "#EXTINF:11.344644,\n" \
      "1080-7mbps00000.ts\n" \
      "#EXTINF:11.261233,\n" \
      "1080-7mbps00001.ts\n" \
      "#EXT-X-ENDLIST\n"

    io = StringIO.open
    writer = M3u8::Writer.new io
    writer.write playlist
    expect(io.string).to eq output

    options = { version: 1, cache: false, target: 12, sequence: 1 }
    playlist = M3u8::Playlist.new options
    playlist.add_segment 11.344644, '1080-7mbps00000.ts'

    output = "#EXTM3U\n" \
      "#EXT-X-VERSION:1\n" \
      "#EXT-X-MEDIA-SEQUENCE:1\n" \
      "#EXT-X-ALLOW-CACHE:NO\n" \
      "#EXT-X-TARGETDURATION:12\n" \
      "#EXTINF:11.344644,\n" \
      "1080-7mbps00000.ts\n" \
      "#EXT-X-ENDLIST\n"

    io = StringIO.open
    writer = M3u8::Writer.new io
    writer.write playlist
    expect(io.string).to eq output
  end

  it 'should raise error on write if item types are mixed' do
    playlist = M3u8::Playlist.new

    hash = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
             bitrate: 540, playlist: 'test.url' }
    item = M3u8::PlaylistItem.new(hash)
    playlist.items.push item

    hash = { duration: 10.991, segment: 'test.ts' }
    item = M3u8::SegmentItem.new(hash)
    playlist.items.push item

    message = 'Playlist is invalid.'
    io = StringIO.new
    writer = M3u8::Writer.new io
    expect { writer.write playlist }
      .to raise_error(M3u8::PlaylistTypeError, message)
  end
end
