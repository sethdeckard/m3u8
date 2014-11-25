module M3u8
  class PlaylistItem
    attr_accessor :program_id, :width, :height, :codecs, :bitrate, :playlist

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def resolution
      return if width.nil?
      "#{width}x#{height}"  
    end

    def to_s
      "#EXT-X-STREAM-INF:PROGRAM-ID=#{program_id},#{resolution_format}" +
        %(CODECS="#{codecs}",BANDWIDTH=#{bitrate}\n#{playlist})
    end

    private 

    def resolution_format
      return if resolution.nil?
      "RESOLUTION=#{resolution},"
    end
  end
end
