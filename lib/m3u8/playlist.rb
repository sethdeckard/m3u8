# frozen_string_literal: true
module M3u8
  # Playlist represents an m3u8 playlist, it can be a master playlist or a set
  # of media segments
  class Playlist
    attr_accessor :items, :version, :cache, :target, :sequence,
                  :discontinuity_sequence, :type, :iframes_only,
                  :independent_segments

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

    def master?
      return @master unless @master.nil?
      return false if playlist_size.zero? && segment_size.zero?
      playlist_size > 0
    end

    def to_s
      output = StringIO.open
      write(output)
      output.string
    end

    def valid?
      return false if playlist_size > 0 && segment_size > 0
      true
    end

    def duration
      duration = 0.0
      items.each do |item|
        duration += item.duration if item.is_a?(M3u8::SegmentItem)
      end
      duration
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
    end

    def defaults
      {
        sequence: 0,
        target: 10,
        iframes_only: false,
        independent_segments: false
      }
    end

    def playlist_size
      items.count { |item| item.is_a?(PlaylistItem) }
    end

    def segment_size
      items.count { |item| item.is_a?(SegmentItem) }
    end
  end
end
