# frozen_string_literal: true

module M3u8
  # Playlist represents an m3u8 playlist, it can be a master playlist
  # or a set of media segments
  class Playlist
    # @return [Array] list of items in the playlist
    # @return [Integer, nil] EXT-X-VERSION value
    # @return [Boolean, nil] EXT-X-ALLOW-CACHE value
    # @return [Integer] EXT-X-TARGETDURATION value
    # @return [Integer] EXT-X-MEDIA-SEQUENCE value
    # @return [Integer, nil] EXT-X-DISCONTINUITY-SEQUENCE value
    # @return [String, nil] EXT-X-PLAYLIST-TYPE (VOD or EVENT)
    # @return [Boolean] whether playlist is I-frames only
    # @return [Boolean] whether segments are independent
    # @return [Boolean] whether playlist is live
    # @return [PartInfItem, nil] EXT-X-PART-INF item
    # @return [ServerControlItem, nil] EXT-X-SERVER-CONTROL item
    attr_accessor :items, :version, :cache, :target, :sequence,
                  :discontinuity_sequence, :type, :iframes_only,
                  :independent_segments, :live, :part_inf,
                  :server_control

    # @param options [Hash] playlist attributes
    def initialize(options = {})
      assign_options(options)
      @items = []
    end

    # Build a playlist using a DSL block.
    # @param options [Hash] playlist attributes
    # @yield [Builder] block receives builder instance
    # @return [Playlist] frozen playlist
    def self.build(options = {}, &block)
      playlist = new(options)
      builder = Builder.new(playlist)
      if block.arity == 1
        yield builder
      else
        builder.instance_eval(&block)
      end
      playlist.freeze
    end

    # Generate a codecs string from codec options.
    # @param options [Hash] codec options (:profile, :level, etc.)
    # @return [String, nil] codecs string
    def self.codecs(options = {})
      item = PlaylistItem.new(options)
      item.codecs
    end

    # Parse an m3u8 playlist from a String or IO.
    # @param input [String, IO] playlist content
    # @return [Playlist] frozen playlist
    def self.read(input)
      reader = Reader.new
      reader.read(input)
    end

    # Write the playlist to an IO object.
    # @param output [IO] writable IO object
    # @return [void]
    def write(output)
      writer = Writer.new(output)
      writer.write(self)
    end

    # Whether this is a live (non-VOD) media playlist.
    # @return [Boolean]
    def live?
      return false if master?

      @live
    end

    # Whether this is a master (multivariant) playlist.
    # @return [Boolean]
    def master?
      return @master unless @master.nil?
      return false if playlist_size.zero? && segment_size.zero?

      playlist_size.positive?
    end

    # Freeze the playlist and all its items.
    # @return [Playlist]
    def freeze
      items.each { |item| freeze_item(item) }
      items.freeze
      part_inf&.freeze
      server_control&.freeze
      super
    end

    # Render the playlist as an m3u8 string.
    # @return [String]
    def to_s
      output = StringIO.open
      write(output)
      output.string
    end

    # Collect validation errors for the playlist.
    # @return [Array<String>] list of error messages
    def errors
      [].tap do |errors|
        validate_mixed_items(errors)
        validate_target_duration(errors)
        validate_segment_items(errors)
        validate_playlist_items(errors)
        validate_media_items(errors)
        validate_key_items(errors)
        validate_session_key_items(errors)
        validate_session_data_items(errors)
        validate_part_items(errors)
      end
    end

    # Whether the playlist passes all validations.
    # @return [Boolean]
    def valid?
      errors.empty?
    end

    # @return [Array<SegmentItem>]
    def segments
      items.grep(SegmentItem)
    end

    # @return [Array<PlaylistItem>]
    def playlists
      items.grep(PlaylistItem)
    end

    # @return [Array<MediaItem>]
    def media_items
      items.grep(MediaItem)
    end

    # @return [Array<KeyItem>]
    def keys
      items.grep(KeyItem)
    end

    # @return [Array<MapItem>]
    def maps
      items.grep(MapItem)
    end

    # @return [Array<DateRangeItem>]
    def date_ranges
      items.grep(DateRangeItem)
    end

    # @return [Array<PartItem>]
    def parts
      items.grep(PartItem)
    end

    # @return [Array<SessionDataItem>]
    def session_data
      items.grep(SessionDataItem)
    end

    # @return [Array<SessionKeyItem>]
    def session_keys
      items.grep(SessionKeyItem)
    end

    # Total duration of all segments.
    # @return [Float]
    def duration
      segments.sum(&:duration)
    end

    private

    def freeze_item(item)
      item.byterange&.freeze if item.respond_to?(:byterange)
      item.program_date_time&.freeze if item.respond_to?(:program_date_time)
      item.client_attributes&.freeze if item.respond_to?(:client_attributes)
      item.freeze
    end

    def assign_options(options)
      options = defaults.merge(options)

      @version = options[:version]
      @sequence = options[:sequence]
      @discontinuity_sequence = options[:discontinuity_sequence]
      @cache = options[:cache]
      @target = options[:target]
      @type = options[:type]
      @iframes_only = options[:iframes_only]
      @independent_segments = options[:independent_segments]
      @master = options[:master]
      @live = options[:live]
      @part_inf = options[:part_inf]
      @server_control = options[:server_control]
    end

    def defaults
      {
        sequence: 0,
        target: 10,
        iframes_only: false,
        independent_segments: false,
        live: false
      }
    end

    def validate_part_items(errors)
      parts.each do |item|
        errors << 'Part item requires a URI' if item.uri.nil?
        errors << 'Part item requires a duration' if item.duration.nil?
      end
    end

    def validate_session_data_items(errors)
      session_data.each do |item|
        errors << 'Session data item requires a data ID' if item.data_id.nil?
        if !item.value.nil? && !item.uri.nil?
          errors << 'Session data item cannot have both value and URI'
        elsif item.value.nil? && item.uri.nil?
          errors << 'Session data item requires a value or URI'
        end
      end
    end

    def validate_key_items(errors)
      keys.each do |item|
        next if item.method == 'NONE'

        next unless item.uri.nil?

        errors << 'Key item requires a URI ' \
                  'when method is not NONE'
      end
    end

    def validate_session_key_items(errors)
      session_keys.each do |item|
        next if item.method == 'NONE'

        next unless item.uri.nil?

        errors << 'Session key item requires a URI ' \
                  'when method is not NONE'
      end
    end

    def validate_playlist_items(errors)
      playlists.each do |item|
        unless item.bandwidth&.positive?
          errors << 'Playlist item requires a bandwidth'
        end
        errors << 'Playlist item requires a URI' if item.uri.nil?
      end
    end

    def validate_media_items(errors)
      media_items.each do |item|
        errors << 'Media item requires a type' if item.type.nil?
        errors << 'Media item requires a group ID' if item.group_id.nil?
        errors << 'Media item requires a name' if item.name.nil?
      end
    end

    def validate_segment_items(errors)
      segments.each do |segment|
        errors << 'Segment item requires a segment URI' if segment.segment.nil?
        if segment.duration&.negative?
          errors << 'Segment item has negative duration'
        end
      end
    end

    def validate_target_duration(errors)
      return if master?

      max = segments.filter_map { |s| s.duration&.round }.max
      return if max.nil? || target >= max

      errors << "Target duration #{target} is less than " \
                "segment duration of #{max}"
    end

    def validate_mixed_items(errors)
      return unless playlist_size.positive? && segment_size.positive?

      errors << 'Playlist contains both master and media items'
    end

    def playlist_size
      playlists.size
    end

    def segment_size
      segments.size
    end
  end
end
