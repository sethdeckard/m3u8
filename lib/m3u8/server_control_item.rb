# frozen_string_literal: true

module M3u8
  # ServerControlItem represents an EXT-X-SERVER-CONTROL tag which
  # provides directives for Low-Latency HLS delivery.
  class ServerControlItem
    extend M3u8
    include AttributeFormatter

    # @return [Float, nil] skip threshold in seconds
    # @return [Boolean, nil] whether dateranges can be skipped
    # @return [Float, nil] hold-back duration in seconds
    # @return [Float, nil] part hold-back duration in seconds
    # @return [Boolean, nil] whether blocking reload is supported
    attr_accessor :can_skip_until, :can_skip_dateranges, :hold_back,
                  :part_hold_back, :can_block_reload

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-SERVER-CONTROL tag.
    # @param text [String] raw tag line
    # @return [ServerControlItem]
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

    # Render as an m3u8 EXT-X-SERVER-CONTROL tag.
    # @return [String]
    def to_s
      "#EXT-X-SERVER-CONTROL:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      [unquoted_format('CAN-SKIP-UNTIL', can_skip_until),
       can_skip_dateranges_format,
       unquoted_format('HOLD-BACK', hold_back),
       unquoted_format('PART-HOLD-BACK', part_hold_back),
       can_block_reload_format].compact.join(',')
    end

    def can_skip_dateranges_format
      return unless can_skip_dateranges

      'CAN-SKIP-DATERANGES=YES'
    end

    def can_block_reload_format
      return unless can_block_reload

      'CAN-BLOCK-RELOAD=YES'
    end
  end
end
