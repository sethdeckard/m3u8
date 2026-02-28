# frozen_string_literal: true

module M3u8
  class CLI
    # InspectCommand displays metadata about a playlist
    class InspectCommand
      def initialize(playlist, stdout)
        @playlist = playlist
        @stdout = stdout
      end

      def run
        if @playlist.master?
          print_master
        else
          print_media
        end
        0
      end

      private

      def print_media
        field 'Type', 'Media'
        field 'Version', @playlist.version
        field 'Sequence', @playlist.sequence
        field 'Target', @playlist.target
        field 'Duration', duration_value
        field 'Playlist', @playlist.type
        field 'Cache', cache_value
        @stdout.puts
        field 'Segments', @playlist.segments.size
        field 'Keys', @playlist.keys.size
        field 'Maps', @playlist.maps.size
      end

      def print_master
        0
      end

      def duration_value
        format('%<s>gs', s: @playlist.duration)
      end

      def cache_value
        return unless @playlist.cache == false

        'No'
      end

      def field(label, value)
        return if value.nil?

        @stdout.puts format('%-12<label>s%<value>s',
                            label: "#{label}:", value: value)
      end
    end
  end
end
