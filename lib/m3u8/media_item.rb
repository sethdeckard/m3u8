module M3u8
  # MediaItem represents a set of #EXT-X-MEDIA attributes
  class MediaItem
    attr_accessor :type, :group, :language, :name, :auto, :default, :uri
  end
end
