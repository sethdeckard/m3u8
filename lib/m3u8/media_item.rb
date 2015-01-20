module M3u8
  # MediaItem represents a set of EXT-X-MEDIA attributes
  class MediaItem
    attr_accessor :type, :group, :language, :assoc_language, :name, :auto,
                  :default, :uri, :forced

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
    
    def to_s
      attributes = [type_format,
                    group_format,
                    language_format,
                    assoc_language_format,
                    name_format,
                    auto_format,
                    default_format,
                    uri_format,
                    forced_format].compact.join(',')
      "#EXT-X-MEDIA:#{attributes}"
    end

    private

    def type_format
      "TYPE=#{type}"
    end

    def group_format
      %(GROUP-ID="#{group}")
    end

    def language_format
      return if language.nil?
      %(LANGUAGE="#{language}")
    end

    def assoc_language_format
      return if assoc_language.nil?
      %(ASSOC-LANGUAGE="#{assoc_language}")
    end

    def name_format
      %(NAME="#{name}")
    end

    def auto_format
      return if auto.nil?
      "AUTOSELECT=#{to_yes_no auto}"
    end

    def default_format
      return if default.nil?
      "DEFAULT=#{to_yes_no default}"
    end

    def uri_format
      return if uri.nil?
      %(URI="#{uri}")
    end

    def forced_format
      return if forced.nil?
      "FORCED=#{to_yes_no forced}"
    end

    def to_yes_no(boolean)
      boolean ==  true ? 'YES' : 'NO'
    end
  end
end
