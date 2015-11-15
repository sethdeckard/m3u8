require 'spec_helper'

describe M3u8::ByteRange do
  it 'should provide m3u8 format representation' do
    hash = { length: 4500, start: 600 }
    item = M3u8::ByteRange.new(hash)
    output = item.to_s
    expected = '4500@600'
    expect(output).to eq expected

    hash = { length: 3300 }
    item = M3u8::ByteRange.new(hash)
    output = item.to_s
    expected = '3300'
    expect(output).to eq expected
  end

  it 'should parse instance from string' do
    input = '3500@300'
    range = M3u8::ByteRange.parse(input)
    expect(range.length).to eq 3500
    expect(range.start).to eq 300

    input = '4000'
    range = M3u8::ByteRange.parse(input)
    expect(range.length).to eq 4000
    expect(range.start).to be_nil
  end
end
