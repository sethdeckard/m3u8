# frozen_string_literal: true
require 'spec_helper'

describe M3u8::DiscontinuityItem do
  it 'should provide m3u8 format representation' do
    item = M3u8::DiscontinuityItem.new
    output = item.to_s
    expected = "#EXT-X-DISCONTINUITY\n"
    expect(output).to eq expected
  end
end
