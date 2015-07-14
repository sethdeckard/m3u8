require 'spec_helper'

describe M3u8::TimeItem do
  it 'should provide m3u8 format representation' do
    options = { time: '2010-02-19T14:54:23.031' }
    item = M3u8::TimeItem.new(options)
    output = item.to_s
    expected = '#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031'
    expect(output).to eq expected

    options = { time: Time.iso8601('2010-02-19T14:54:23.031Z') }
    item = M3u8::TimeItem.new(options)
    output = item.to_s
    expected = '#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23Z'
    expect(output).to eq expected
  end

  it 'should parse m3u8 text into instance' do
    input = '#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z'
    item = M3u8::TimeItem.parse(input)
    expect(item.time).to eq Time.iso8601('2010-02-19T14:54:23.031Z')
  end
end
