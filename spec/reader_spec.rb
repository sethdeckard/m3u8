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
    expect(item.resolution).to be nil
  end

  it 'should parse segment playlist' do
    file = File.open 'spec/fixtures/playlist.m3u8'
    reader = M3u8::Reader.new
    playlist = reader.read file
    expect(playlist.master?).to be false
    expect(playlist.version).to be 4
    expect(playlist.sequence).to be 1
    expect(playlist.cache).to be false
    expect(playlist.target).to be 12

    item = playlist.items[0]
    expect(item).to be_a(M3u8::SegmentItem)
    expect(item.duration).to eq 11.344644

    item = playlist.items[1]
    expect(item).to be_a(M3u8::SegmentTagDiscontinuity)

    expect(playlist.items.size).to eq 139
  end
end
