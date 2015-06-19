require 'spec_helper'

describe M3u8::MapItem do
  it 'should provide m3u8 format representation' do
    hash = { uri: 'frelo/prog_index.m3u8', byterange_length: 4500,
             byterange_start: 600 }
    item = M3u8::MapItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-MAP:URI="frelo/prog_index.m3u8",' \
               'BYTERANGE:"4500@600"'
    expect(output).to eq expected

    hash = { uri: 'frehi/prog_index.m3u8' }
    item = M3u8::MapItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-MAP:URI="frehi/prog_index.m3u8"'
    expect(output).to eq expected
  end
end
