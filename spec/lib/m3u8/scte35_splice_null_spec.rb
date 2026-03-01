# frozen_string_literal: true

require 'spec_helper'

describe M3u8::Scte35SpliceNull do
  describe '#new' do
    it 'should create an empty splice null command' do
      command = described_class.new
      expect(command).to be_a(described_class)
    end
  end
end
