# frozen_string_literal: true

module M3u8
  # SkipItem represents an EXT-X-SKIP tag used in Playlist Delta
  # Updates for Low-Latency HLS.
  class SkipItem
    extend M3u8

    attr_accessor :skipped_segments, :recently_removed_dateranges

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      SkipItem.new(
        skipped_segments:
          attributes['SKIPPED-SEGMENTS'].to_i,
        recently_removed_dateranges:
          attributes['RECENTLY-REMOVED-DATERANGES']
      )
    end

    def to_s
      "#EXT-X-SKIP:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      [skipped_segments_format,
       recently_removed_dateranges_format].compact.join(',')
    end

    def skipped_segments_format
      "SKIPPED-SEGMENTS=#{skipped_segments}"
    end

    def recently_removed_dateranges_format
      return if recently_removed_dateranges.nil?

      %(RECENTLY-REMOVED-DATERANGES="#{recently_removed_dateranges}")
    end
  end
end
