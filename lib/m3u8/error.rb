# frozen_string_literal: true
module M3u8
  class InvalidPlaylistError < StandardError
  end

  class MissingCodecError < StandardError
  end

  class PlaylistTypeError < StandardError
  end
end
