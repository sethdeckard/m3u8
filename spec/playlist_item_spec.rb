require 'spec_helper'

describe M3u8::PlaylistItem do
  it 'should initialize with hash' do
    hash = { program_id: 1, resolution: '1920x1080', codecs: 'avc',
             bandwidth: 540, playlist: 'test.url' }
    item = M3u8::PlaylistItem.new(hash)
    expect(item.program_id).to eq 1
    expect(item.resolution).to eq '1920x1080'
    expect(item.codecs).to eq 'avc'
    expect(item.bandwidth).to eq 540
    expect(item.playlist).to eq 'test.url'
  end

  it 'should provide m3u8 format representation' do
    hash = { program_id: 1, resolution: '1920x1080', codecs: 'avc',
             bandwidth: 540, playlist: 'test.url' }
    item = M3u8::PlaylistItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080,' +
               %(CODECS="avc",BANDWIDTH=540\ntest.url)
    expect(output).to eq expected
  end
end
