# frozen_string_literal: true

module M3u8
  # ServerControlItem represents an EXT-X-SERVER-CONTROL tag which
  # provides directives for Low-Latency HLS delivery.
  class ServerControlItem
    extend M3u8

    attr_accessor :can_skip_until, :can_skip_dateranges, :hold_back,
                  :part_hold_back, :can_block_reload

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      ServerControlItem.new(
        can_skip_until: parse_float(attributes['CAN-SKIP-UNTIL']),
        can_skip_dateranges:
          parse_yes_no(attributes['CAN-SKIP-DATERANGES']),
        hold_back: parse_float(attributes['HOLD-BACK']),
        part_hold_back: parse_float(attributes['PART-HOLD-BACK']),
        can_block_reload:
          parse_yes_no(attributes['CAN-BLOCK-RELOAD'])
      )
    end

    def to_s
      "#EXT-X-SERVER-CONTROL:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      [can_skip_until_format,
       can_skip_dateranges_format,
       hold_back_format,
       part_hold_back_format,
       can_block_reload_format].compact.join(',')
    end

    def can_skip_until_format
      return if can_skip_until.nil?

      "CAN-SKIP-UNTIL=#{can_skip_until}"
    end

    def can_skip_dateranges_format
      return unless can_skip_dateranges

      'CAN-SKIP-DATERANGES=YES'
    end

    def hold_back_format
      return if hold_back.nil?

      "HOLD-BACK=#{hold_back}"
    end

    def part_hold_back_format
      return if part_hold_back.nil?

      "PART-HOLD-BACK=#{part_hold_back}"
    end

    def can_block_reload_format
      return unless can_block_reload

      'CAN-BLOCK-RELOAD=YES'
    end
  end
end
