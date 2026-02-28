# frozen_string_literal: true

module M3u8
  class CLI
    # ValidateCommand checks playlist validity
    class ValidateCommand
      def initialize(playlist, stdout)
        @playlist = playlist
        @stdout = stdout
      end

      def run
        if @playlist.valid?
          @stdout.puts 'Valid'
          0
        else
          @stdout.puts 'Invalid: mixed playlist and segment items'
          1
        end
      end
    end
  end
end
