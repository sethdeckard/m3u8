require 'spec_helper'

describe M3u8::DateRangeItem do
  describe '#parse' do
    it 'should parse m3u8 tag into instance' do
      item = M3u8::DateRangeItem.new
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
    end

    it 'should ignore optional attributes' do
      item = M3u8::DateRangeItem.new
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
    end
  end
end
