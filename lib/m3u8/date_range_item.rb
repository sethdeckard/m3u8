# frozen_string_literal: true

module M3u8
  # DateRangeItem represents a #EXT-X-DATERANGE tag
  class DateRangeItem
    include M3u8

    attr_accessor :id, :class_name, :start_date, :end_date, :duration,
                  :planned_duration, :scte35_cmd, :scte35_out, :scte35_in,
                  :cue, :end_on_next, :client_attributes,
                  :asset_uri, :asset_list, :resume_offset,
                  :playout_limit, :restrict, :snap,
                  :timeline_occupies, :timeline_style,
                  :content_may_vary

    INTERSTITIAL_KEYS = %w[
      X-ASSET-URI X-ASSET-LIST X-RESUME-OFFSET X-PLAYOUT-LIMIT
      X-RESTRICT X-SNAP X-TIMELINE-OCCUPIES X-TIMELINE-STYLE
      X-CONTENT-MAY-VARY
    ].freeze

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
      @cue = attributes['CUE']
      @end_on_next = attributes.key?('END-ON-NEXT')
      parse_interstitials(attributes)
      @client_attributes = parse_client_attributes(attributes)
    end

    def to_s
      "#EXT-X-DATERANGE:#{formatted_attributes}"
    end

    def scte35_cmd_info
      Scte35.parse(scte35_cmd) unless scte35_cmd.nil?
    end

    def scte35_out_info
      Scte35.parse(scte35_out) unless scte35_out.nil?
    end

    def scte35_in_info
      Scte35.parse(scte35_in) unless scte35_in.nil?
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
       interstitial_formats,
       scte35_cmd_format,
       scte35_out_format,
       scte35_in_format,
       cue_format,
       end_on_next_format].flatten.compact.join(',')
    end

    def class_name_format
      quoted_format('CLASS', class_name)
    end

    def end_date_format
      quoted_format('END-DATE', end_date)
    end

    def duration_format
      unquoted_format('DURATION', duration)
    end

    def planned_duration_format
      unquoted_format('PLANNED-DURATION', planned_duration)
    end

    def client_attributes_format
      return if client_attributes.nil? || client_attributes.empty?

      client_attributes.map do |attribute|
        value = attribute.last
        value_format = decimal?(value) ? value : %("#{value}")
        "#{attribute.first}=#{value_format}"
      end
    end

    def decimal?(value)
      val = value.to_s
      return true if val =~ /\A\d+\Z/

      begin
        true if Float(val)
      rescue StandardError
        false
      end
    end

    def parse_interstitials(attributes)
      @asset_uri = attributes['X-ASSET-URI']
      @asset_list = attributes['X-ASSET-LIST']
      @resume_offset = parse_float(attributes['X-RESUME-OFFSET'])
      @playout_limit = parse_float(attributes['X-PLAYOUT-LIMIT'])
      @restrict = attributes['X-RESTRICT']
      @snap = attributes['X-SNAP']
      @timeline_occupies = attributes['X-TIMELINE-OCCUPIES']
      @timeline_style = attributes['X-TIMELINE-STYLE']
      @content_may_vary = attributes['X-CONTENT-MAY-VARY']
    end

    def interstitial_formats
      [asset_uri_format, asset_list_format,
       resume_offset_format, playout_limit_format,
       restrict_format, snap_format,
       timeline_occupies_format, timeline_style_format,
       content_may_vary_format]
    end

    def asset_uri_format
      quoted_format('X-ASSET-URI', asset_uri)
    end

    def asset_list_format
      quoted_format('X-ASSET-LIST', asset_list)
    end

    def resume_offset_format
      unquoted_format('X-RESUME-OFFSET', resume_offset)
    end

    def playout_limit_format
      unquoted_format('X-PLAYOUT-LIMIT', playout_limit)
    end

    def restrict_format
      quoted_format('X-RESTRICT', restrict)
    end

    def snap_format
      quoted_format('X-SNAP', snap)
    end

    def timeline_occupies_format
      quoted_format('X-TIMELINE-OCCUPIES', timeline_occupies)
    end

    def timeline_style_format
      quoted_format('X-TIMELINE-STYLE', timeline_style)
    end

    def content_may_vary_format
      quoted_format('X-CONTENT-MAY-VARY', content_may_vary)
    end

    def scte35_cmd_format
      unquoted_format('SCTE35-CMD', scte35_cmd)
    end

    def scte35_out_format
      unquoted_format('SCTE35-OUT', scte35_out)
    end

    def scte35_in_format
      unquoted_format('SCTE35-IN', scte35_in)
    end

    def cue_format
      quoted_format('CUE', cue)
    end

    def end_on_next_format
      return unless end_on_next

      'END-ON-NEXT=YES'
    end

    def quoted_format(key, value)
      %(#{key}="#{value}") unless value.nil?
    end

    def unquoted_format(key, value)
      "#{key}=#{value}" unless value.nil?
    end

    def parse_client_attributes(attributes)
      attributes.select do |key|
        key.start_with?('X-') && !INTERSTITIAL_KEYS.include?(key)
      end
    end
  end
end
