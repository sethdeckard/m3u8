module M3u8
  # Playlist represents an m3u8 playlist, it can be a master playlist or a set
  # of media segments
  class Playlist
    attr_accessor :items, :version, :cache, :target, :sequence, :type,
                  :iframes_only

    def initialize(options = {})
      assign_options options
      self.items = []
    end

    def self.codecs(options = {})
      item = PlaylistItem.new options
      item.codecs
    end

    def self.read(input)
      reader = Reader.new
      reader.read input
    end

    def write(output)
      writer = Writer.new output
      writer.write self
    end

    def master?
      return false if playlist_size == 0 && segment_size == 0
      playlist_size > 0
    end

    def to_s
      output = StringIO.open
      write output
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
      options = {
        version: 3,
        sequence: 0,
        cache: true,
        target: 10,
        iframes_only: false
      }.merge options

      self.version = options[:version]
      self.sequence = options[:sequence]
      self.cache = options[:cache]
      self.target = options[:target]
      self.type = options[:type]
      self.iframes_only = options[:iframes_only]
    end

    def playlist_size
      items.select { |item| item.is_a?(PlaylistItem) }.size
    end

    def segment_size
      items.select { |item| item.is_a?(SegmentItem) }.size
    end
  end
end
