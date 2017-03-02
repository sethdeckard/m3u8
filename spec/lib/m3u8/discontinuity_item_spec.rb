# frozen_string_literal: true
require 'spec_helper'

describe M3u8::DiscontinuityItem do
  it 'should provide m3u8 format representation' do
    item = M3u8::DiscontinuityItem.new
    expect(item.to_s).to eq("#EXT-X-DISCONTINUITY\n")
  end
end
