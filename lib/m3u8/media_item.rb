module M3u8
  # MediaItem represents a set of EXT-X-MEDIA attributes
  class MediaItem
    attr_accessor :type, :group_id, :language, :assoc_language, :name,
                  :autoselect, :default, :uri, :forced

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def to_s
      attributes = [type_format,
                    group_id_format,
                    language_format,
                    assoc_language_format,
                    name_format,
                    autoselect_format,
                    default_format,
                    uri_format,
                    forced_format].compact.join(',')
      "#EXT-X-MEDIA:#{attributes}"
    end

    private

    def type_format
      "TYPE=#{type}"
    end

    def group_id_format
      %(GROUP-ID="#{group_id}")
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

    def autoselect_format
      return if autoselect.nil?
      "AUTOSELECT=#{to_yes_no autoselect}"
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
