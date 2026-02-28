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
        0
      end
    end
  end
end
