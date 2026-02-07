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

    def valid?
      return false if playlist_size.positive? && segment_size.positive?

      true
    end

    def segments
      items.select { |item| item.is_a?(SegmentItem) }
    end

    def playlists
      items.select { |item| item.is_a?(PlaylistItem) }
    end

    def media_items
      items.select { |item| item.is_a?(MediaItem) }
    end

    def keys
      items.select { |item| item.is_a?(KeyItem) }
    end

    def maps
      items.select { |item| item.is_a?(MapItem) }
    end

    def date_ranges
      items.select { |item| item.is_a?(DateRangeItem) }
    end

    def parts
      items.select { |item| item.is_a?(PartItem) }
    end

    def session_data
      items.select { |item| item.is_a?(SessionDataItem) }
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

    def playlist_size
      playlists.size
    end

    def segment_size
      segments.size
    end
  end
end
