module M3u8
  class Playlist
    attr_accessor :items, :version, :cache, :target, :sequence
    NON_MASTER_ERROR_MESSAGE = 'Playlist is not a master playlist, playlist' \
      ' can not be added.'
    MASTER_ERROR_MESSAGE = 'Playlist is a master playlist, segment can not ' \
      'be added.'

    def initialize(options = {})
      assign_options options
      self.items = []
    end

    def self.codecs(options = {})
      item = PlaylistItem.new options
      item.codecs
    end

    def add_playlist(program_id, playlist, bitrate, options = {})
      validate_playlist_type true

      params = { program_id: program_id, playlist: playlist, bitrate: bitrate,
                 width: options[:width], height: options[:height],
                 audio: options[:audio], profile: options[:profile],
                 level: options[:level] }
      item = PlaylistItem.new params
      items.push item
    end

    def add_segment(duration, segment)
      validate_playlist_type false

      params = { duration: duration, segment: segment }
      item = SegmentItem.new params
      items.push item
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

    private

    def assign_options(options)
      options = {
        version: 3,
        sequence: 0,
        cache: true,
        target: 10
      }.merge options

      self.version = options[:version]
      self.sequence = options[:sequence]
      self.cache = options[:cache]
      self.target = options[:target]
    end

    def validate_playlist_type(master)
      return if items.size == 0
      if master && !master?
        fail PlaylistTypeError, NON_MASTER_ERROR_MESSAGE
      elsif !master && master?
        fail PlaylistTypeError, MASTER_ERROR_MESSAGE
      end
    end

    def playlist_size
      items.select { |item| item.is_a?(PlaylistItem) }.size
    end

    def segment_size
      items.select { |item| item.is_a?(SegmentItem) }.size
    end
  end
end
