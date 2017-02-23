module M3u8
  # DateRangeItem represents a #EXT-X-DATERANGE tag
  class DateRangeItem
    include M3u8
    attr_accessor :id, :class_name, :start_date, :end_date, :duration,
                  :planned_duration, :scte35_cmd, :scte35_out, :scte35_in,
                  :end_on_next, :client_attributes

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def parse(text)
      attributes = parse_attributes(text)
      @id = attributes['ID']
      @class_name = attributes['CLASS']
      @start_date = attributes['START-DATE']
      @end_date = attributes['END-DATE']
      @duration = parse_float(attributes['DURATION'])
      @planned_duration = parse_float(attributes['PLANNED-DURATION'])
      @scte35_cmd = attributes['SCTE35-CMD']
      @scte35_out = attributes['SCTE35-OUT']
      @scte35_in = attributes['SCTE35-IN']
      @end_on_next = attributes.key?('END-ON-NEXT') ? true : false
      @client_attributes = parse_client_attributes(attributes)
    end

    private

    def parse_client_attributes(attributes)
      attributes.select { |key| key.start_with?('X-') }
    end
  end
end
