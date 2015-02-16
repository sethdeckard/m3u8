require 'spec_helper'

describe M3u8::SegmentTagDiscontinuity do
  it 'should provide m3u8 format representation' do
    item = M3u8::SegmentTagDiscontinuity.new
    output = item.to_s
    expected = "#EXT-X-DISCONTINUITY\n"
    expect(output).to eq expected
  end
end
