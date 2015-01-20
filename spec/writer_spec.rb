require 'spec_helper'

describe M3u8::Writer do
  it 'should render master playlist' do
    options = { playlist: 'playlist_url', bitrate: 6400,
                audio_codec: 'mp3' }
    item = M3u8::PlaylistItem.new options
    playlist = M3u8::Playlist.new
    playlist.items.push item

    output = "#EXTM3U\n" +
             %(#EXT-X-STREAM-INF:CODECS="mp4a.40.34") +
             ",BANDWIDTH=6400\nplaylist_url\n"

    io = StringIO.open
    writer = M3u8::Writer.new io
    writer.write playlist
    expect(io.string).to eq output

    options = { program_id: '1', playlist: 'playlist_url', bitrate: 6400,
                audio_codec: 'mp3' }
    item = M3u8::PlaylistItem.new options
    playlist = M3u8::Playlist.new
    playlist.items.push item

    output = "#EXTM3U\n" +
             %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34") +
             ",BANDWIDTH=6400\nplaylist_url\n"

    io = StringIO.open
    writer = M3u8::Writer.new io
    writer.write playlist
    expect(io.string).to eq output

    options = { program_id: '2', playlist: 'playlist_url', bitrate: 50_000,
                width: 1920, height: 1080, profile: 'high', level: 4.1,
                audio_codec: 'aac-lc' }
    item = M3u8::PlaylistItem.new options
    playlist = M3u8::Playlist.new
    playlist.items.push item

    output = "#EXTM3U\n" \
             '#EXT-X-STREAM-INF:PROGRAM-ID=2,RESOLUTION=1920x1080,' +
             %(CODECS="avc1.640028,mp4a.40.2",BANDWIDTH=50000\n) +
             "playlist_url\n"

    io = StringIO.open
    writer = M3u8::Writer.new io
    writer.write playlist
    expect(io.string).to eq output

    playlist = M3u8::Playlist.new
    options = { program_id: '1', playlist: 'playlist_url', bitrate: 6400,
                audio_codec: 'mp3' }
    item = M3u8::PlaylistItem.new options
    playlist.items.push item
    options = { program_id: '2', playlist: 'playlist_url', bitrate: 50_000,
                width: 1920, height: 1080, profile: 'high', level: 4.1,
                audio_codec: 'aac-lc' }
    item = M3u8::PlaylistItem.new options
    playlist.items.push item

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
    options = { duration: 11.344644, segment: '1080-7mbps00000.ts' }
    item =  M3u8::SegmentItem.new options
    playlist = M3u8::Playlist.new
    playlist.items.push item

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

    options = { duration: 11.261233, segment: '1080-7mbps00001.ts' }
    item =  M3u8::SegmentItem.new options
    playlist.items.push item

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

    options = { version: 1, cache: false, target: 12, sequence: 1,
                type: 'EVENT' }
    playlist = M3u8::Playlist.new options
    options = { duration: 11.344644, segment: '1080-7mbps00000.ts' }
    item =  M3u8::SegmentItem.new options
    playlist.items.push item

    output = "#EXTM3U\n" \
      "EXT-X-PLAYLIST-TYPE:EVENT\n" \
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
