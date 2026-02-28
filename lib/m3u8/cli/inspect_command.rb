# frozen_string_literal: true

module M3u8
  class CLI
    # InspectCommand displays metadata about a playlist
    class InspectCommand
      MEDIA_WIDTH = 12
      MASTER_WIDTH = 23

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
        field 'Type', 'Media', MEDIA_WIDTH
        field 'Version', @playlist.version, MEDIA_WIDTH
        field 'Sequence', @playlist.sequence, MEDIA_WIDTH
        field 'Target', @playlist.target, MEDIA_WIDTH
        field 'Duration', duration_value, MEDIA_WIDTH
        field 'Playlist', @playlist.type, MEDIA_WIDTH
        field 'Cache', cache_value, MEDIA_WIDTH
        @stdout.puts
        field 'Segments', @playlist.segments.size, MEDIA_WIDTH
        field 'Keys', @playlist.keys.size, MEDIA_WIDTH
        field 'Maps', @playlist.maps.size, MEDIA_WIDTH
      end

      def print_master
        field 'Type', 'Master', MASTER_WIDTH
        field 'Independent Segments',
              independent_segments_value, MASTER_WIDTH
        @stdout.puts
        print_variants
        print_media_items
        field 'Session Keys',
              @playlist.session_keys.size, MASTER_WIDTH
        field 'Session Data',
              @playlist.session_data.size, MASTER_WIDTH
      end

      def print_variants
        variants = @playlist.playlists
        field 'Variants', variants.size, MASTER_WIDTH
        variants.each { |v| @stdout.puts variant_line(v) }
      end

      def print_media_items
        items = @playlist.media_items
        field 'Media', items.size, MASTER_WIDTH
        items.each do |m|
          @stdout.puts "  #{m.type}  #{m.group_id}  #{m.name}"
        end
      end

      def variant_line(variant)
        res = variant.resolution || ''
        format('  %-11<res>s%<bw>s bps  %<uri>s',
               res: res, bw: variant.bandwidth, uri: variant.uri)
      end

      def independent_segments_value
        return unless @playlist.independent_segments

        'Yes'
      end

      def duration_value
        format('%<s>gs', s: @playlist.duration)
      end

      def cache_value
        return unless @playlist.cache == false

        'No'
      end

      def field(label, value, width)
        return if value.nil?

        @stdout.puts format("%-#{width}<label>s%<value>s",
                            label: "#{label}:", value: value)
      end
    end
  end
end
