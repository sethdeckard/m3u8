# frozen_string_literal: true
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

    def to_s
      "#EXT-X-DATERANGE:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      [%(ID="#{id}"),
       class_name_format,
       %(START-DATE="#{start_date}"),
       end_date_format,
       duration_format,
       planned_duration_format,
       client_attributes_format,
       scte35_cmd_format,
       scte35_out_format,
       scte35_in_format,
       end_on_next_format].compact.join(',')
    end

    def class_name_format
      return if class_name.nil?
      %(CLASS="#{class_name}")
    end

    def end_date_format
      return if end_date.nil?
      %(END-DATE="#{end_date}")
    end

    def duration_format
      return if duration.nil?
      "DURATION=#{duration}"
    end

    def planned_duration_format
      return if planned_duration.nil?
      "PLANNED-DURATION=#{planned_duration}"
    end

    def client_attributes_format
      return if client_attributes.nil?
      client_attributes.map do |attribute|
        value = attribute.last
        value_format = decimal?(value) ? value : %("#{value}")
        "#{attribute.first}=#{value_format}"
      end
    end

    def decimal?(value)
      return true if value =~ /\A\d+\Z/
      begin
        return true if Float(value)
      rescue
        false
      end
    end

    def scte35_cmd_format
      return if scte35_cmd.nil?
      "SCTE35-CMD=#{scte35_cmd}"
    end

    def scte35_out_format
      return if scte35_out.nil?
      "SCTE35-OUT=#{scte35_out}"
    end

    def scte35_in_format
      return if scte35_in.nil?
      "SCTE35-IN=#{scte35_in}"
    end

    def end_on_next_format
      return unless end_on_next
      'END-ON-NEXT=YES'
    end

    def parse_client_attributes(attributes)
      attributes.select { |key| key.start_with?('X-') }
    end
  end
end
