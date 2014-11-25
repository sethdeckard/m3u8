module M3u8
  class PlaylistItem
    attr_accessor :program_id, :resolution, :codecs, :bandwidth, :playlist

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def to_s
      "#EXT-X-STREAM-INF:PROGRAM-ID=#{program_id},RESOLUTION=#{resolution}," +
        %(CODECS="#{codecs}",BANDWIDTH=#{bandwidth}\n#{playlist})
    end
  end
end
