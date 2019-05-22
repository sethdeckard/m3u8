# frozen_string_literal: true
module M3u8
  # CueOut represents a EXT-X-CUE-OUT tag to indicate a
  # SCTE35 cue out for server side ad insertion
  class CueOut
    def initialize(duration)
      @slate_duration = duration
    end

    def to_s
      "EXT-X-CUE-OUT:DURATION=#{@slate_duration}\n"
    end
  end
end
