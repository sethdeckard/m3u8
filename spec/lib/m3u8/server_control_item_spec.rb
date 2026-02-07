# frozen_string_literal: true

require 'spec_helper'

describe M3u8::ServerControlItem do
  describe '.new' do
    it 'assigns attributes from options' do
      options = { can_skip_until: 36.0, can_skip_dateranges: true,
                  hold_back: 15.0, part_hold_back: 3.0,
                  can_block_reload: true }
      item = described_class.new(options)
      expect(item.can_skip_until).to eq(36.0)
      expect(item.can_skip_dateranges).to be true
      expect(item.hold_back).to eq(15.0)
      expect(item.part_hold_back).to eq(3.0)
      expect(item.can_block_reload).to be true
    end
  end

  describe '.parse' do
    it 'parses tag with all attributes' do
      tag = '#EXT-X-SERVER-CONTROL:CAN-SKIP-UNTIL=36.0,' \
            'CAN-SKIP-DATERANGES=YES,HOLD-BACK=15.0,' \
            'PART-HOLD-BACK=3.0,CAN-BLOCK-RELOAD=YES'
      item = described_class.parse(tag)
      expect(item.can_skip_until).to eq(36.0)
      expect(item.can_skip_dateranges).to be true
      expect(item.hold_back).to eq(15.0)
      expect(item.part_hold_back).to eq(3.0)
      expect(item.can_block_reload).to be true
    end

    it 'parses tag without optional attributes' do
      tag = '#EXT-X-SERVER-CONTROL:PART-HOLD-BACK=1.0,' \
            'CAN-BLOCK-RELOAD=YES'
      item = described_class.parse(tag)
      expect(item.can_skip_until).to be_nil
      expect(item.can_skip_dateranges).to be false
      expect(item.part_hold_back).to eq(1.0)
      expect(item.can_block_reload).to be true
    end
  end

  describe '#to_s' do
    it 'returns tag with all attributes' do
      options = { can_skip_until: 36.0, can_skip_dateranges: true,
                  hold_back: 15.0, part_hold_back: 3.0,
                  can_block_reload: true }
      item = described_class.new(options)
      expected = '#EXT-X-SERVER-CONTROL:CAN-SKIP-UNTIL=36.0,' \
                 'CAN-SKIP-DATERANGES=YES,HOLD-BACK=15.0,' \
                 'PART-HOLD-BACK=3.0,CAN-BLOCK-RELOAD=YES'
      expect(item.to_s).to eq(expected)
    end

    it 'returns tag with only required attributes' do
      options = { part_hold_back: 1.0, can_block_reload: true }
      item = described_class.new(options)
      expected = '#EXT-X-SERVER-CONTROL:PART-HOLD-BACK=1.0,' \
                 'CAN-BLOCK-RELOAD=YES'
      expect(item.to_s).to eq(expected)
    end
  end
end
