# frozen_string_literal: true
module M3u8
  # CueIn represents a EXT-X-CUE-IN tag to indicate a
  # SCTE35 cue in for server side ad insertion
  class CueIn
    def to_s
      "EXT-X-CUE-IN\n"
    end
  end
end
