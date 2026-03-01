# frozen_string_literal: true

require 'spec_helper'

describe M3u8::Scte35SegmentationDescriptor do
  # Builds a full SCTE-35 hex string with a time_signal command and descriptors
  def build_hex_with_descriptors(descriptor_bytes)
    # time_signal with pts=90000: FE 00 01 5F 90 (5 bytes, type 0x06)
    cmd_bytes = 'FE00015F90'
    cmd_len = 5
    desc_loop_length = descriptor_bytes.length
    desc_hex = descriptor_bytes.map { |b| format('%02X', b) }.join
    desc_loop_hex = format('%04X', desc_loop_length)

    # section_length = 11(header) + cmd_len + 2(desc_loop_len) + desc_loop + 4(CRC)
    section_length = 11 + cmd_len + 2 + desc_loop_length + 4
    header = splice_info_header(section_length, cmd_len)

    "0x#{header}06#{cmd_bytes}#{desc_loop_hex}#{desc_hex}DEADBEEF"
  end

  def splice_info_header(section_length, cmd_length)
    section_header = format('%04X', 0x3000 | section_length)
    tier_cmd = format('%06X', (0xFFF << 12) | cmd_length)
    "FC#{section_header}00000000000000#{tier_cmd}"
  end

  # Builds segmentation_descriptor bytes (tag=0x02, identifier=CUEI)
  def segmentation_descriptor(fields)
    # descriptor_tag(8): 0x02
    # descriptor_length(8): computed
    # identifier(32): CUEI = 0x43554549
    # segmentation_event_id(32)
    # segmentation_event_cancel_indicator(1) + reserved(7)
    # if not cancelled:
    #   program_segmentation_flag(1)=1 + segmentation_duration_flag(1)
    #   + delivery_not_restricted_flag(1)=1 + reserved(5)=11111
    #   if duration_flag: segmentation_duration(40)
    #   segmentation_upid_type(8) + segmentation_upid_length(8)
    #   + upid data
    #   segmentation_type_id(8) + segment_num(8) + segments_expected(8)
    bytes = [0x43, 0x55, 0x45, 0x49] # CUEI identifier
    bytes += to_bytes(fields[:event_id], 4)

    if fields[:cancel]
      bytes += [0xFF] # cancel=1, reserved=1111111
    else
      bytes << 0x7F # cancel=0, reserved=1111111
      duration_flag = fields[:duration] ? 1 : 0
      # program_seg=1, duration_flag, delivery_not_restricted=1, reserved=11111
      flags = (1 << 7) | (duration_flag << 6) | (1 << 5) | 0x1F
      bytes << flags

      if fields[:duration]
        bytes += to_bytes(fields[:duration], 5) # 40-bit duration
      end

      upid = fields[:upid] || ''
      bytes << (fields[:upid_type] || 0)
      bytes << upid.length
      bytes += upid.bytes if upid.length.positive?

      bytes << fields[:type_id]
      bytes << (fields[:segment_num] || 0)
      bytes << (fields[:segments_expected] || 0)
    end

    # Prepend tag and length
    [0x02, bytes.length] + bytes
  end

  def to_bytes(value, count)
    count.times.map { |i| (value >> (8 * (count - 1 - i))) & 0xFF }
  end

  describe 'parsing via Scte35.parse' do
    it 'should parse a segmentation descriptor with ad-start type' do
      desc = segmentation_descriptor(
        event_id: 0x00000001, type_id: 0x30,
        segment_num: 0, segments_expected: 0
      )
      hex = build_hex_with_descriptors(desc)
      result = M3u8::Scte35.parse(hex)

      expect(result.descriptors.length).to eq(1)
      seg = result.descriptors.first
      expect(seg).to be_a(described_class)
      expect(seg.segmentation_event_id).to eq(1)
      expect(seg.segmentation_type_id).to eq(0x30)
      expect(seg.segment_num).to eq(0)
      expect(seg.segments_expected).to eq(0)
    end

    it 'should parse a segmentation descriptor with duration' do
      desc = segmentation_descriptor(
        event_id: 0x00000002, type_id: 0x34,
        duration: 2_700_000, segment_num: 1, segments_expected: 2
      )
      hex = build_hex_with_descriptors(desc)
      result = M3u8::Scte35.parse(hex)
      seg = result.descriptors.first

      expect(seg.segmentation_duration).to eq(2_700_000)
      expect(seg.segmentation_type_id).to eq(0x34)
      expect(seg.segment_num).to eq(1)
      expect(seg.segments_expected).to eq(2)
    end

    it 'should parse a segmentation descriptor with UPID' do
      desc = segmentation_descriptor(
        event_id: 0x00000003, type_id: 0x30,
        upid_type: 0x09, upid: 'SIGNAL123'
      )
      hex = build_hex_with_descriptors(desc)
      result = M3u8::Scte35.parse(hex)
      seg = result.descriptors.first

      expect(seg.segmentation_upid_type).to eq(0x09)
      expect(seg.segmentation_upid).to eq('SIGNAL123')
    end

    it 'should parse a cancelled segmentation descriptor' do
      desc = segmentation_descriptor(event_id: 0x00000004, cancel: true)
      hex = build_hex_with_descriptors(desc)
      result = M3u8::Scte35.parse(hex)
      seg = result.descriptors.first

      expect(seg.segmentation_event_id).to eq(4)
      expect(seg.segmentation_event_cancel_indicator).to be true
      expect(seg.segmentation_type_id).to be_nil
    end

    it 'should store raw bytes for unknown descriptor tags' do
      # Unknown tag 0xFF with 4 bytes of identifier + 2 bytes data
      unknown_desc = [0xFF, 0x06, 0x43, 0x55, 0x45, 0x49, 0xAA, 0xBB]
      hex = build_hex_with_descriptors(unknown_desc)
      result = M3u8::Scte35.parse(hex)

      expect(result.descriptors.length).to eq(1)
      expect(result.descriptors.first).to be_a(String)
    end
  end
end
