# frozen_string_literal: true

module M3u8
  # Playlist represents an m3u8 playlist, it can be a master playlist or a set
  # of media segments
  class Playlist
    attr_accessor :items, :version, :cache, :target, :sequence,
                  :discontinuity_sequence, :type, :iframes_only,
                  :independent_segments, :live, :part_inf,
                  :server_control

    def initialize(options = {})
      assign_options(options)
      @items = []
    end

    def self.build(options = {}, &block)
      playlist = new(options)
      builder = Builder.new(playlist)
      if block.arity == 1
        yield builder
      else
        builder.instance_eval(&block)
      end
      playlist
    end

    def self.codecs(options = {})
      item = PlaylistItem.new(options)
      item.codecs
    end

    def self.read(input)
      reader = Reader.new
      reader.read(input)
    end

    def write(output)
      writer = Writer.new(output)
      writer.write(self)
    end

    def live?
      return false if master?

      @live
    end

    def master?
      return @master unless @master.nil?
      return false if playlist_size.zero? && segment_size.zero?

      playlist_size.positive?
    end

    def to_s
      output = StringIO.open
      write(output)
      output.string
    end

    def errors
      [].tap do |errors|
        validate_mixed_items(errors)
        validate_target_duration(errors)
        validate_segment_items(errors)
      end
    end

    def valid?
      errors.empty?
    end

    def segments
      items.grep(SegmentItem)
    end

    def playlists
      items.grep(PlaylistItem)
    end

    def media_items
      items.grep(MediaItem)
    end

    def keys
      items.grep(KeyItem)
    end

    def maps
      items.grep(MapItem)
    end

    def date_ranges
      items.grep(DateRangeItem)
    end

    def parts
      items.grep(PartItem)
    end

    def session_data
      items.grep(SessionDataItem)
    end

    def session_keys
      items.grep(SessionKeyItem)
    end

    def duration
      segments.sum(&:duration)
    end

    private

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

    def validate_segment_items(errors)
      segments.each do |segment|
        errors << 'Segment item requires a segment URI' if segment.segment.nil?
        errors << 'Segment item has negative duration' if segment.duration&.negative?
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
