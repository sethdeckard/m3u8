# frozen_string_literal: true

require 'spec_helper'

describe M3u8::SegmentItem do
  it 'should initialize with hash' do
    hash = { duration: 10.991, segment: 'test.ts' }
    item = M3u8::SegmentItem.new(hash)
    expect(item.duration).to eq 10.991
    expect(item.segment).to eq 'test.ts'
    expect(item.comment).to be_nil
    expect(item.byterange).to be_nil
    expect(item.program_date_time).to be_nil

    hash = { duration: 10.991, segment: 'test.ts', comment: 'anything',
             byterange: { length: 4500, start: 600 } }
    item = M3u8::SegmentItem.new(hash)
    expect(item.duration).to eq 10.991
    expect(item.byterange.length).to eq 4500
    expect(item.byterange.start).to eq 600
    expect(item.segment).to eq 'test.ts'
    expect(item.comment).to eq 'anything'
  end

  it 'should provide m3u8 format representation' do
    time_hash = { time: '2010-02-19T14:54:23.031' }
    time_item = M3u8::TimeItem.new(time_hash)

    hash = { duration: 10.991, segment: 'test.ts',
             program_date_time: time_item }
    item = M3u8::SegmentItem.new(hash)
    output = item.to_s
    date_time_output = item.program_date_time.to_s
    expected = "#EXTINF:10.991,\n#{date_time_output}\ntest.ts"
    expect(output).to eq expected

    hash = { duration: 10.991, segment: 'test.ts', comment: 'anything' }
    item = M3u8::SegmentItem.new(hash)
    output = item.to_s
    expected = "#EXTINF:10.991,anything\ntest.ts"
    expect(output).to eq expected

    hash = { duration: 10.991, segment: 'test.ts', comment: 'anything',
             byterange: { length: 4500, start: 600 } }
    item = M3u8::SegmentItem.new(hash)
    output = item.to_s
    expected = "#EXTINF:10.991,anything\n#EXT-X-BYTERANGE:4500@600\ntest.ts"
    expect(output).to eq expected

    hash = { duration: 10.991, segment: 'test.ts', comment: 'anything',
             byterange: { length: 4500 } }
    item = M3u8::SegmentItem.new(hash)
    output = item.to_s
    expected = "#EXTINF:10.991,anything\n#EXT-X-BYTERANGE:4500\ntest.ts"
    expect(output).to eq expected
  end

  it 'wraps raw Time in program_date_time as TimeItem' do
    time = Time.iso8601('2020-11-25T20:27:00Z')
    hash = { duration: 10, segment: 'segment.aac',
             program_date_time: time }
    item = M3u8::SegmentItem.new(hash)
    output = item.to_s
    expected = "#EXTINF:10,\n" \
               "#EXT-X-PROGRAM-DATE-TIME:2020-11-25T20:27:00Z\n" \
               'segment.aac'
    expect(output).to eq expected
  end
end
