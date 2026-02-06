# frozen_string_literal: true

require 'spec_helper'

describe M3u8::MapItem do
  it 'should provide m3u8 format representation' do
    hash = { uri: 'frelo/prog_index.m3u8',
             byterange: { length: 4500, start: 600 } }
    item = M3u8::MapItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-MAP:URI="frelo/prog_index.m3u8",' \
               'BYTERANGE="4500@600"'
    expect(output).to eq expected

    hash = { uri: 'frehi/prog_index.m3u8' }
    item = M3u8::MapItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-MAP:URI="frehi/prog_index.m3u8"'
    expect(output).to eq expected
  end

  it 'should parse m3u8 text into instance' do
    input = '#EXT-X-MAP:URI="frelo/prog_index.m3u8",' \
            'BYTERANGE="3500@300"'

    item = M3u8::MapItem.parse(input)

    expect(item.uri).to eq 'frelo/prog_index.m3u8'
    expect(item.byterange.length).to eq 3500
    expect(item.byterange.start).to eq 300

    input = '#EXT-X-MAP:URI="frelo/prog_index.m3u8"'

    item = M3u8::MapItem.parse(input)

    expect(item.uri).to eq 'frelo/prog_index.m3u8'
    expect(item.byterange).to be_nil
  end
end
