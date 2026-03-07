# frozen_string_literal: true

module M3u8
  # SkipItem represents an EXT-X-SKIP tag used in Playlist Delta
  # Updates for Low-Latency HLS.
  class SkipItem
    extend M3u8
    include AttributeFormatter

    # @return [Integer, nil] number of skipped segments
    # @return [String, nil] recently removed dateranges
    attr_accessor :skipped_segments, :recently_removed_dateranges

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-SKIP tag.
    # @param text [String] raw tag line
    # @return [SkipItem]
    def self.parse(text)
      attributes = parse_attributes(text)
      SkipItem.new(
        skipped_segments:
          attributes['SKIPPED-SEGMENTS'].to_i,
        recently_removed_dateranges:
          attributes['RECENTLY-REMOVED-DATERANGES']
      )
    end

    # Render as an m3u8 EXT-X-SKIP tag.
    # @return [String]
    def to_s
      "#EXT-X-SKIP:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      [unquoted_format('SKIPPED-SEGMENTS', skipped_segments),
       quoted_format('RECENTLY-REMOVED-DATERANGES',
                     recently_removed_dateranges)].compact.join(',')
    end
  end
end
