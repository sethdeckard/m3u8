require 'spec_helper'

describe M3u8::SegmentItem do
  it 'should initialize with hash' do
    hash = { time: 10.991, segment: 'test.ts' }
    item = M3u8::SegmentItem.new(hash)
    expect(item.time).to eq 10.991
    expect(item.segment).to eq 'test.ts'
  end

  it 'should provide m3u8 format representation' do
    hash = { time: 10.991, segment: 'test.ts' }
    item = M3u8::SegmentItem.new(hash)
    output = item.to_s
    expected = "#EXTINF:10.991,\ntest.ts"
    expect(output).to eq expected
  end
end
