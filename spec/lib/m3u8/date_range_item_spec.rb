# frozen_string_literal: true

require 'spec_helper'

describe M3u8::DateRangeItem do
  describe '#new' do
    it 'should assign attributes via option hash' do
      options = { id: 'test_id', class_name: 'test_class',
                  start_date: '2014-03-05T11:15:00Z',
                  end_date: '2014-03-05T11:16:00Z', duration: 60.1,
                  planned_duration: 59.993,
                  scte35_out: '0xFC002F0000000000FF0',
                  scte35_in: '0xFC002F0000000000FF1',
                  scte35_cmd: '0xFC002F0000000000FF2',
                  cue: 'PRE', end_on_next: true,
                  asset_uri: 'http://example.com/ad.m3u8',
                  asset_list: 'http://example.com/ads.json',
                  resume_offset: 10.5,
                  playout_limit: 30.0,
                  restrict: 'SKIP,JUMP',
                  snap: 'OUT',
                  timeline_occupies: 'RANGE',
                  timeline_style: 'HIGHLIGHT',
                  content_may_vary: 'YES',
                  client_attributes: { 'X-CUSTOM' => 45.3 } }
      item = described_class.new(options)

      expect(item.id).to eq('test_id')
      expect(item.class_name).to eq('test_class')
      expect(item.start_date).to eq('2014-03-05T11:15:00Z')
      expect(item.end_date).to eq('2014-03-05T11:16:00Z')
      expect(item.duration).to eq(60.1)
      expect(item.planned_duration).to eq(59.993)
      expect(item.scte35_out).to eq('0xFC002F0000000000FF0')
      expect(item.scte35_in).to eq('0xFC002F0000000000FF1')
      expect(item.scte35_cmd).to eq('0xFC002F0000000000FF2')
      expect(item.cue).to eq('PRE')
      expect(item.end_on_next).to be true
      expect(item.asset_uri).to eq('http://example.com/ad.m3u8')
      expect(item.asset_list).to eq('http://example.com/ads.json')
      expect(item.resume_offset).to eq(10.5)
      expect(item.playout_limit).to eq(30.0)
      expect(item.restrict).to eq('SKIP,JUMP')
      expect(item.snap).to eq('OUT')
      expect(item.timeline_occupies).to eq('RANGE')
      expect(item.timeline_style).to eq('HIGHLIGHT')
      expect(item.content_may_vary).to eq('YES')
      expect(item.client_attributes.empty?).to be false
      expect(item.client_attributes['X-CUSTOM']).to eq(45.3)
    end
  end

  describe '.parse' do
    it 'should parse m3u8 tag into instance' do
      line = '#EXT-X-DATERANGE:ID="splice-6FFFFFF0",CLASS="test_class",' \
             'START-DATE="2014-03-05T11:15:00Z",' \
             'END-DATE="2014-03-05T11:16:00Z",DURATION=60.1,' \
             'PLANNED-DURATION=59.993,SCTE35-OUT=0xFC002F0000000000FF0,' \
             'SCTE35-IN=0xFC002F0000000000FF1,' \
             'SCTE35-CMD=0xFC002F0000000000FF2,' \
             'X-ASSET-URI="http://example.com/ad.m3u8",' \
             'X-ASSET-LIST="http://example.com/ads.json",' \
             'X-RESUME-OFFSET=10.5,' \
             'X-PLAYOUT-LIMIT=30.0,' \
             'X-RESTRICT="SKIP,JUMP",' \
             'X-SNAP="OUT",' \
             'X-TIMELINE-OCCUPIES="RANGE",' \
             'X-TIMELINE-STYLE="HIGHLIGHT",' \
             'X-CONTENT-MAY-VARY="YES",' \
             'CUE="PRE",' \
             'END-ON-NEXT=YES'
      item = described_class.parse(line)

      expect(item.id).to eq('splice-6FFFFFF0')
      expect(item.class_name).to eq('test_class')
      expect(item.start_date).to eq('2014-03-05T11:15:00Z')
      expect(item.end_date).to eq('2014-03-05T11:16:00Z')
      expect(item.duration).to eq(60.1)
      expect(item.planned_duration).to eq(59.993)
      expect(item.scte35_out).to eq('0xFC002F0000000000FF0')
      expect(item.scte35_in).to eq('0xFC002F0000000000FF1')
      expect(item.scte35_cmd).to eq('0xFC002F0000000000FF2')
      expect(item.asset_uri).to eq('http://example.com/ad.m3u8')
      expect(item.asset_list).to eq('http://example.com/ads.json')
      expect(item.resume_offset).to eq(10.5)
      expect(item.playout_limit).to eq(30.0)
      expect(item.restrict).to eq('SKIP,JUMP')
      expect(item.snap).to eq('OUT')
      expect(item.timeline_occupies).to eq('RANGE')
      expect(item.timeline_style).to eq('HIGHLIGHT')
      expect(item.content_may_vary).to eq('YES')
      expect(item.cue).to eq('PRE')
      expect(item.end_on_next).to be true
      expect(item.client_attributes.empty?).to be true
    end

    it 'should ignore optional attributes' do
      line = '#EXT-X-DATERANGE:ID="splice-6FFFFFF0",' \
             'START-DATE="2014-03-05T11:15:00Z"'
      item = described_class.parse(line)

      expect(item.id).to eq('splice-6FFFFFF0')
      expect(item.class_name).to be_nil
      expect(item.start_date).to eq('2014-03-05T11:15:00Z')
      expect(item.end_date).to be_nil
      expect(item.duration).to be_nil
      expect(item.planned_duration).to be_nil
      expect(item.scte35_out).to be_nil
      expect(item.scte35_in).to be_nil
      expect(item.scte35_cmd).to be_nil
      expect(item.end_on_next).to be false
      expect(item.client_attributes.empty?).to be true
    end

    it 'should parse client-defined attributes' do
      line = '#EXT-X-DATERANGE:ID="splice-6FFFFFF0",' \
             'START-DATE="2014-03-05T11:15:00Z",' \
             'X-CUSTOM-VALUE="test_value",'
      item = described_class.parse(line)

      expect(item.client_attributes['X-CUSTOM-VALUE']).to eq('test_value')
    end
  end

  describe '#to_s' do
    it 'should render m3u8 tag' do
      options = { id: 'test_id', class_name: 'test_class',
                  start_date: '2014-03-05T11:15:00Z',
                  end_date: '2014-03-05T11:16:00Z', duration: 60.1,
                  planned_duration: 59.993,
                  scte35_out: '0xFC002F0000000000FF0',
                  scte35_in: '0xFC002F0000000000FF1',
                  scte35_cmd: '0xFC002F0000000000FF2',
                  asset_uri: 'http://example.com/ad.m3u8',
                  asset_list: 'http://example.com/ads.json',
                  resume_offset: 10.5,
                  playout_limit: 30.0,
                  restrict: 'SKIP,JUMP',
                  snap: 'OUT',
                  timeline_occupies: 'RANGE',
                  timeline_style: 'HIGHLIGHT',
                  content_may_vary: 'YES',
                  cue: 'POST,ONCE', end_on_next: true,
                  client_attributes: { 'X-CUSTOM' => 45.3,
                                       'X-CUSTOM-TEXT' =>
                                         'test_value' } }
      item = described_class.new(options)

      expected = '#EXT-X-DATERANGE:ID="test_id",' \
                 'CLASS="test_class",' \
                 'START-DATE="2014-03-05T11:15:00Z",' \
                 'END-DATE="2014-03-05T11:16:00Z",' \
                 'DURATION=60.1,' \
                 'PLANNED-DURATION=59.993,' \
                 'X-CUSTOM=45.3,' \
                 'X-CUSTOM-TEXT="test_value",' \
                 'X-ASSET-URI="http://example.com/ad.m3u8",' \
                 'X-ASSET-LIST="http://example.com/ads.json",' \
                 'X-RESUME-OFFSET=10.5,' \
                 'X-PLAYOUT-LIMIT=30.0,' \
                 'X-RESTRICT="SKIP,JUMP",' \
                 'X-SNAP="OUT",' \
                 'X-TIMELINE-OCCUPIES="RANGE",' \
                 'X-TIMELINE-STYLE="HIGHLIGHT",' \
                 'X-CONTENT-MAY-VARY="YES",' \
                 'SCTE35-CMD=0xFC002F0000000000FF2,' \
                 'SCTE35-OUT=0xFC002F0000000000FF0,' \
                 'SCTE35-IN=0xFC002F0000000000FF1,' \
                 'CUE="POST,ONCE",' \
                 'END-ON-NEXT=YES'

      expect(item.to_s).to eq(expected)
    end

    it 'should ignore optional attributes' do
      options = { id: 'test_id', start_date: '2014-03-05T11:15:00Z' }
      item = described_class.new(options)

      expected = '#EXT-X-DATERANGE:ID="test_id",' \
                 'START-DATE="2014-03-05T11:15:00Z"'

      expect(item.to_s).to eq(expected)
    end
  end

  describe '#scte35_out_info' do
    it 'should return parsed Scte35 when scte35_out is set' do
      hex = '0xFC301100000000000000FFF000000000DEADBEEF'
      item = described_class.new(scte35_out: hex)
      result = item.scte35_out_info

      expect(result).to be_a(M3u8::Scte35)
      expect(result.table_id).to eq(0xFC)
      expect(result.to_s).to eq(hex)
    end

    it 'should return nil when scte35_out is nil' do
      item = described_class.new
      expect(item.scte35_out_info).to be_nil
    end
  end

  describe '#scte35_in_info' do
    it 'should return parsed Scte35 when scte35_in is set' do
      hex = '0xFC301100000000000000FFF000000000DEADBEEF'
      item = described_class.new(scte35_in: hex)
      result = item.scte35_in_info

      expect(result).to be_a(M3u8::Scte35)
    end

    it 'should return nil when scte35_in is nil' do
      item = described_class.new
      expect(item.scte35_in_info).to be_nil
    end
  end

  describe '#scte35_cmd_info' do
    it 'should return parsed Scte35 when scte35_cmd is set' do
      hex = '0xFC301100000000000000FFF000000000DEADBEEF'
      item = described_class.new(scte35_cmd: hex)
      result = item.scte35_cmd_info

      expect(result).to be_a(M3u8::Scte35)
    end

    it 'should return nil when scte35_cmd is nil' do
      item = described_class.new
      expect(item.scte35_cmd_info).to be_nil
    end
  end
end
