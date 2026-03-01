# frozen_string_literal: true

module M3u8
  # Represents a segmentation_descriptor (tag 0x02) in SCTE-35
  class Scte35SegmentationDescriptor
    CUEI_IDENTIFIER = 0x43554549
    DESCRIPTOR_TAG = 0x02

    attr_reader :segmentation_event_id, :segmentation_event_cancel_indicator,
                :segmentation_type_id, :segmentation_duration,
                :segmentation_upid_type, :segmentation_upid,
                :segment_num, :segments_expected

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse_from(reader, _length)
      attrs = { segmentation_event_id: reader.read_bits(32) }
      attrs[:segmentation_event_cancel_indicator] = reader.read_flag
      reader.skip_bits(7) # reserved
      return new(**attrs) if attrs[:segmentation_event_cancel_indicator]

      parse_segmentation_detail(reader, attrs)
    end

    def self.parse_segmentation_detail(reader, attrs)
      reader.read_flag # program_segmentation_flag
      duration_flag = reader.read_flag
      reader.skip_bits(6) # delivery_not_restricted + reserved/flags

      attrs[:segmentation_duration] = reader.read_bits(40) if duration_flag
      parse_upid(reader, attrs)
      attrs[:segmentation_type_id] = reader.read_bits(8)
      attrs[:segment_num] = reader.read_bits(8)
      attrs[:segments_expected] = reader.read_bits(8)
      new(**attrs)
    end

    def self.parse_upid(reader, attrs)
      attrs[:segmentation_upid_type] = reader.read_bits(8)
      upid_length = reader.read_bits(8)
      return if upid_length.zero?

      attrs[:segmentation_upid] = reader.read_bytes(upid_length).force_encoding('UTF-8')
    end

    private_class_method :parse_segmentation_detail, :parse_upid
  end
end
