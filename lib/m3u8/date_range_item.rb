# frozen_string_literal: true

module M3u8
  # DateRangeItem represents a #EXT-X-DATERANGE tag
  class DateRangeItem
    extend M3u8
    include AttributeFormatter

    # @return [String, nil] unique date range identifier
    # @return [String, nil] CLASS attribute
    # @return [String, nil] start date (ISO 8601)
    # @return [String, nil] end date (ISO 8601)
    # @return [Float, nil] duration in seconds
    # @return [Float, nil] planned duration in seconds
    # @return [String, nil] SCTE-35 command hex string
    # @return [String, nil] SCTE-35 out hex string
    # @return [String, nil] SCTE-35 in hex string
    # @return [String, nil] CUE attribute
    # @return [Boolean, nil] END-ON-NEXT flag
    # @return [Hash, nil] client-defined X- attributes
    # @return [String, nil] interstitial asset URI
    # @return [String, nil] interstitial asset list URI
    # @return [Float, nil] interstitial resume offset
    # @return [Float, nil] interstitial playout limit
    # @return [String, nil] interstitial restrict value
    # @return [String, nil] interstitial snap value
    # @return [String, nil] interstitial timeline occupies
    # @return [String, nil] interstitial timeline style
    # @return [String, nil] content may vary flag
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

    # @param options [Hash] attribute key-value pairs
    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-DATERANGE tag.
    # @param text [String] raw tag line
    # @return [DateRangeItem]
    def self.parse(text)
      attributes = parse_attributes(text)
      options = parse_base_attributes(attributes)
                .merge(parse_interstitials(attributes))
                .merge(client_attributes:
                         parse_client_attributes(attributes))
      DateRangeItem.new(options)
    end

    def self.parse_base_attributes(attributes)
      { id: attributes['ID'],
        class_name: attributes['CLASS'],
        start_date: attributes['START-DATE'],
        end_date: attributes['END-DATE'],
        duration: parse_float(attributes['DURATION']),
        planned_duration:
          parse_float(attributes['PLANNED-DURATION']),
        scte35_cmd: attributes['SCTE35-CMD'],
        scte35_out: attributes['SCTE35-OUT'],
        scte35_in: attributes['SCTE35-IN'],
        cue: attributes['CUE'],
        end_on_next: attributes.key?('END-ON-NEXT') }
    end
    private_class_method :parse_base_attributes

    def self.parse_interstitials(attributes)
      { asset_uri: attributes['X-ASSET-URI'],
        asset_list: attributes['X-ASSET-LIST'],
        resume_offset:
          parse_float(attributes['X-RESUME-OFFSET']),
        playout_limit:
          parse_float(attributes['X-PLAYOUT-LIMIT']),
        restrict: attributes['X-RESTRICT'],
        snap: attributes['X-SNAP'],
        timeline_occupies:
          attributes['X-TIMELINE-OCCUPIES'],
        timeline_style: attributes['X-TIMELINE-STYLE'],
        content_may_vary:
          attributes['X-CONTENT-MAY-VARY'] }
    end
    private_class_method :parse_interstitials

    # Render as an m3u8 EXT-X-DATERANGE tag.
    # @return [String]
    def to_s
      "#EXT-X-DATERANGE:#{formatted_attributes}"
    end

    # Parse SCTE-35 command data.
    # @return [Scte35, nil]
    def scte35_cmd_info
      Scte35.parse(scte35_cmd) unless scte35_cmd.nil?
    end

    # Parse SCTE-35 out data.
    # @return [Scte35, nil]
    def scte35_out_info
      Scte35.parse(scte35_out) unless scte35_out.nil?
    end

    # Parse SCTE-35 in data.
    # @return [Scte35, nil]
    def scte35_in_info
      Scte35.parse(scte35_in) unless scte35_in.nil?
    end

    def self.parse_client_attributes(attributes)
      attributes.select do |key|
        key.start_with?('X-') && !INTERSTITIAL_KEYS.include?(key)
      end
    end
    private_class_method :parse_client_attributes

    private

    def formatted_attributes
      [%(ID="#{id}"),
       quoted_format('CLASS', class_name),
       %(START-DATE="#{start_date}"),
       quoted_format('END-DATE', end_date),
       unquoted_format('DURATION', float_format(duration)),
       unquoted_format('PLANNED-DURATION', float_format(planned_duration)),
       client_attributes_format,
       interstitial_formats,
       unquoted_format('SCTE35-CMD', scte35_cmd),
       unquoted_format('SCTE35-OUT', scte35_out),
       unquoted_format('SCTE35-IN', scte35_in),
       quoted_format('CUE', cue),
       end_on_next_format].flatten.compact.join(',')
    end

    def client_attributes_format
      return if client_attributes.nil? || client_attributes.empty?

      client_attributes.map do |attribute|
        value = attribute.last
        fmt = decimal?(value) ? float_format(value) : %("#{value}")
        "#{attribute.first}=#{fmt}"
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

    def interstitial_formats
      [quoted_format('X-ASSET-URI', asset_uri),
       quoted_format('X-ASSET-LIST', asset_list),
       unquoted_format('X-RESUME-OFFSET', float_format(resume_offset)),
       unquoted_format('X-PLAYOUT-LIMIT', float_format(playout_limit)),
       quoted_format('X-RESTRICT', restrict),
       quoted_format('X-SNAP', snap),
       quoted_format('X-TIMELINE-OCCUPIES', timeline_occupies),
       quoted_format('X-TIMELINE-STYLE', timeline_style),
       quoted_format('X-CONTENT-MAY-VARY', content_may_vary)]
    end

    def end_on_next_format
      return unless end_on_next

      'END-ON-NEXT=YES'
    end
  end
end
