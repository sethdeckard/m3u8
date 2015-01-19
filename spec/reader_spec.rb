require 'spec_helper'

describe M3u8::Reader do
  it 'should parse master playlist' do
    file = File.open 'spec/fixtures/master.m3u8'
    reader = M3u8::Reader.new
    playlist = reader.read file
    expect(playlist.master?).to be true

    item = playlist.items[0]
    expect(item).to be_a(M3u8::PlaylistItem)
    expect(item.playlist).to eq('hls/1080-7mbps/1080-7mbps.m3u8')
    expect(item.program_id).to eq('1')
    expect(item.width).to eq(1920)
    expect(item.height).to eq(1080)
    expect(item.resolution).to eq('1920x1080')
    expect(item.codecs).to eq('avc1.640028,mp4a.40.2')
    expect(item.bitrate).to eq(5_042_000)

    expect(playlist.items.size).to eq 6

    item = playlist.items.last
    expect(item.resolution).to be_nil
  end

  it 'should parse segment playlist' do
    file = File.open 'spec/fixtures/playlist.m3u8'
    reader = M3u8::Reader.new
    playlist = reader.read file
    expect(playlist.master?).to be false
    expect(playlist.version).to eq 4
    expect(playlist.sequence).to eq 1
    expect(playlist.cache).to be false
    expect(playlist.target).to eq 12
    expect(playlist.type).to eq 'VOD'

    item = playlist.items[0]
    expect(item).to be_a(M3u8::SegmentItem)
    expect(item.duration).to eq 11.344644

    expect(playlist.items.size).to eq 138
  end

  it 'should parse variant playlist with audio options and groups' do
    file = File.open 'spec/fixtures/variant_audio.m3u8'
    reader = M3u8::Reader.new
    playlist = reader.read file

    expect(playlist.master?).to be true
    expect(playlist.items.size).to eq 10

    item = playlist.items[0]
    expect(item).to be_a M3u8::MediaItem
    expect(item.type).to eq 'AUDIO'
    expect(item.group).to eq 'audio-lo'
    expect(item.language).to eq 'eng'
    expect(item.assoc_language).to eq 'spoken'
    expect(item.name).to eq 'English'
    expect(item.auto).to be true
    expect(item.default).to be true
    expect(item.uri).to eq 'englo/prog_index.m3u8'
    expect(item.forced).to be true
  end

  it 'should parse variant playlist with camera angles' do
    file = File.open 'spec/fixtures/variant_angles.m3u8'
    reader = M3u8::Reader.new
    playlist = reader.read file

    expect(playlist.master?).to be true
    expect(playlist.items.size).to eq 11

    item = playlist.items[1]
    expect(item).to be_a M3u8::MediaItem
    expect(item.type).to eq 'VIDEO'
    expect(item.group).to eq '200kbs'
    expect(item.language).to be_nil
    expect(item.name).to eq 'Angle2'
    expect(item.auto).to be true
    expect(item.default).to be false
    expect(item.uri).to eq 'Angle2/200kbs/prog_index.m3u8'

    item = playlist.items[9]
    expect(item.average_bandwidth).to eq 300_001
    expect(item.audio).to eq 'aac'
    expect(item.video).to eq '200kbs'
    expect(item.closed_captions).to eq 'captions'
    expect(item.subtitles).to eq 'subs'
  end
end
