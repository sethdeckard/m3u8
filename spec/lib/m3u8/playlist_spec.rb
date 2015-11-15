require 'spec_helper'

describe M3u8::Playlist do
  it 'should generate codecs string' do
    options = { profile: 'baseline', level: 3.0, audio_codec: 'aac-lc' }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.66.30,mp4a.40.2'
  end

  it 'should render master playlist' do
    options = { uri: 'playlist_url', bandwidth: 6400,
                audio_codec: 'mp3' }
    item = M3u8::PlaylistItem.new options
    playlist = M3u8::Playlist.new
    playlist.items.push item

    output = "#EXTM3U\n" +
             %(#EXT-X-STREAM-INF:CODECS="mp4a.40.34") +
             ",BANDWIDTH=6400\nplaylist_url\n"
    expect(playlist.to_s).to eq output

    options = { program_id: '1', uri: 'playlist_url', bandwidth: 6400,
                audio_codec: 'mp3' }
    item = M3u8::PlaylistItem.new options
    playlist = M3u8::Playlist.new
    playlist.items.push item

    output = "#EXTM3U\n" +
             %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34") +
             ",BANDWIDTH=6400\nplaylist_url\n"
    expect(playlist.to_s).to eq output

    options = { program_id: '2', uri: 'playlist_url', bandwidth: 50_000,
                width: 1920, height: 1080, profile: 'high', level: 4.1,
                audio_codec: 'aac-lc' }
    item = M3u8::PlaylistItem.new options
    playlist = M3u8::Playlist.new
    playlist.items.push item

    output = "#EXTM3U\n" \
             '#EXT-X-STREAM-INF:PROGRAM-ID=2,RESOLUTION=1920x1080,' +
             %(CODECS="avc1.640028,mp4a.40.2",BANDWIDTH=50000\n) +
             "playlist_url\n"

    expect(playlist.to_s).to eq output

    playlist = M3u8::Playlist.new
    options = { program_id: '1', uri: 'playlist_url', bandwidth: 6400,
                audio_codec: 'mp3' }
    item = M3u8::PlaylistItem.new options
    playlist.items.push item
    options = { program_id: '2', uri: 'playlist_url', bandwidth: 50_000,
                width: 1920, height: 1080, profile: 'high', level: 4.1,
                audio_codec: 'aac-lc' }
    item = M3u8::PlaylistItem.new options
    playlist.items.push item

    output = "#EXTM3U\n" +
             %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34") +
             ",BANDWIDTH=6400\nplaylist_url\n#EXT-X-STREAM-INF:PROGRAM-ID=2," +
             %(RESOLUTION=1920x1080,CODECS="avc1.640028,mp4a.40.2") +
             ",BANDWIDTH=50000\nplaylist_url\n"
    expect(playlist.to_s).to eq output
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
    expect(playlist.to_s).to eq output

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
    expect(playlist.to_s).to eq output

    options = { version: 1, cache: false, target: 12, sequence: 1,
                type: 'VOD' }
    playlist = M3u8::Playlist.new options
    options = { duration: 11.344644, segment: '1080-7mbps00000.ts' }
    item =  M3u8::SegmentItem.new options
    playlist.items.push item

    output = "#EXTM3U\n" \
      "#EXT-X-PLAYLIST-TYPE:VOD\n" \
      "#EXT-X-VERSION:1\n" \
      "#EXT-X-MEDIA-SEQUENCE:1\n" \
      "#EXT-X-ALLOW-CACHE:NO\n" \
      "#EXT-X-TARGETDURATION:12\n" \
      "#EXTINF:11.344644,\n" \
      "1080-7mbps00000.ts\n" \
      "#EXT-X-ENDLIST\n"

    expect(playlist.to_s).to eq output
  end

  it 'should write playlist to io' do
    test_io = StringIO.new
    playlist = M3u8::Playlist.new
    options = { program_id: '1', uri: 'playlist_url', bandwidth: 6400,
                audio_codec: 'mp3' }
    item = M3u8::PlaylistItem.new options
    playlist.items.push item
    playlist.write test_io

    output = "#EXTM3U\n" +
             %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34",) +
             "BANDWIDTH=6400\nplaylist_url\n"

    expect(test_io.string).to eq output

    test_io = StringIO.new
    playlist.write test_io

    output = "#EXTM3U\n" +
             %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34",) +
             "BANDWIDTH=6400\nplaylist_url\n"

    expect(test_io.string).to eq output
  end

  it 'should report if it is a master playlist' do
    playlist = M3u8::Playlist.new
    expect(playlist.master?).to be false
    options = { program_id: '1', uri: 'playlist_url', bandwidth: 6400,
                audio_codec: 'mp3' }
    item = M3u8::PlaylistItem.new options
    playlist.items.push item

    expect(playlist.master?).to be true
  end

  it 'should raise error on write if item types are mixed' do
    playlist = M3u8::Playlist.new

    hash = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
             bandwidth: 540, uri: 'test.url' }
    item = M3u8::PlaylistItem.new(hash)
    playlist.items.push item

    hash = { duration: 10.991, segment: 'test.ts' }
    item = M3u8::SegmentItem.new(hash)
    playlist.items.push item

    message = 'Playlist is invalid.'
    io = StringIO.new
    expect { playlist.write io }
      .to raise_error(M3u8::PlaylistTypeError, message)
  end

  it 'should return valid status' do
    playlist = M3u8::Playlist.new
    expect(playlist.valid?).to be true

    hash = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
             bandwidth: 540, uri: 'test.url' }
    item = M3u8::PlaylistItem.new(hash)
    playlist.items.push item
    expect(playlist.valid?).to be true

    hash = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
             bandwidth: 540, uri: 'test.url' }
    item = M3u8::PlaylistItem.new(hash)
    playlist.items.push item
    expect(playlist.valid?).to be true

    hash = { duration: 10.991, segment: 'test.ts' }
    item = M3u8::SegmentItem.new(hash)
    playlist.items.push item

    expect(playlist.valid?).to be false
  end

  it 'should expose options as attributes' do
    options = { version: 1, cache: false, target: 12, sequence: 1,
                type: 'VOD' }
    playlist = M3u8::Playlist.new options
    expect(playlist.version).to be 1
    expect(playlist.cache).to be false
    expect(playlist.target).to be 12
    expect(playlist.sequence).to be 1
    expect(playlist.type).to eq('VOD')
    expect(playlist.iframes_only).to be false
  end

  it 'should allow reading of playlists' do
    file = File.open 'spec/fixtures/master.m3u8'
    playlist = M3u8::Playlist.read file
    expect(playlist.master?).to be true
    expect(playlist.items.size).to eq(7)
  end

  it 'should return the total duration of a playlist' do
    playlist = M3u8::Playlist.new
    item = M3u8::SegmentItem.new(duration: 10.991, segment: 'test_01.ts')
    playlist.items.push item
    item = M3u8::SegmentItem.new(duration: 9.891, segment: 'test_02.ts')
    playlist.items.push item
    item = M3u8::SegmentItem.new(duration: 10.556, segment: 'test_03.ts')
    playlist.items.push item
    item = M3u8::SegmentItem.new(duration: 8.790, segment: 'test_04.ts')
    playlist.items.push item

    expect(playlist.duration.round(3)).to eq(40.228)
  end
end
