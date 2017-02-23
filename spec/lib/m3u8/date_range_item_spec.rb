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
                  scte35_cmd: '0xFC002F0000000000FF2', end_on_next: true,
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
      expect(item.end_on_next).to be true
      expect(item.client_attributes.empty?).to be false
      expect(item.client_attributes['X-CUSTOM']).to eq(45.3)
    end
  end

  describe '#parse' do
    it 'should parse m3u8 tag into instance' do
      item = described_class.new
      line = '#EXT-X-DATERANGE:ID="splice-6FFFFFF0",CLASS="test_class"' \
      'START-DATE="2014-03-05T11:15:00Z",' \
      'END-DATE="2014-03-05T11:16:00Z",DURATION=60.1,' \
      'PLANNED-DURATION=59.993,SCTE35-OUT=0xFC002F0000000000FF0,' \
      'SCTE35-IN=0xFC002F0000000000FF1,' \
      'SCTE35-CMD=0xFC002F0000000000FF2,' \
      'END-ON-NEXT=YES'
      item.parse(line)

      expect(item.id).to eq('splice-6FFFFFF0')
      expect(item.class_name).to eq('test_class')
      expect(item.start_date).to eq('2014-03-05T11:15:00Z')
      expect(item.end_date).to eq('2014-03-05T11:16:00Z')
      expect(item.duration).to eq(60.1)
      expect(item.planned_duration).to eq(59.993)
      expect(item.scte35_out).to eq('0xFC002F0000000000FF0')
      expect(item.scte35_in).to eq('0xFC002F0000000000FF1')
      expect(item.scte35_cmd).to eq('0xFC002F0000000000FF2')
      expect(item.end_on_next).to be true
      expect(item.client_attributes.empty?).to be true
    end

    it 'should ignore optional attributes' do
      item = described_class.new
      line = '#EXT-X-DATERANGE:ID="splice-6FFFFFF0",' \
      'START-DATE="2014-03-05T11:15:00Z"'
      item.parse(line)

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
      item = described_class.new
      line = '#EXT-X-DATERANGE:ID="splice-6FFFFFF0",' \
      'START-DATE="2014-03-05T11:15:00Z",' \
      'X-CUSTOM-VALUE="test_value",'
      item.parse(line)

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
                  scte35_cmd: '0xFC002F0000000000FF2', end_on_next: true,
                  client_attributes: { 'X-CUSTOM' => 45.3,
                                       'X-CUSTOM-TEXT' => 'test_value' } }
      item = described_class.new(options)

      expected = '#EXT-X-DATERANGE:ID="test_id",CLASS="test_class",' \
      'START-DATE="2014-03-05T11:15:00Z",' \
      'END-DATE="2014-03-05T11:16:00Z",DURATION=60.1,' \
      'PLANNED-DURATION=59.993,' \
      'X-CUSTOM=45.3,' \
      'X-CUSTOM-TEXT="test_value",' \
      'SCTE35-CMD=0xFC002F0000000000FF2,' \
      'SCTE35-OUT=0xFC002F0000000000FF0,' \
      'SCTE35-IN=0xFC002F0000000000FF1,' \
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
end
