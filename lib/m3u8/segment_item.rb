# frozen_string_literal: true
module M3u8
  # SegmentItem represents EXTINF attributes with the URI that follows,
  # optionally allowing an EXT-X-BYTERANGE tag to be set.
  class SegmentItem
    include M3u8
    attr_accessor :duration, :segment, :comment, :program_date_time,
                  :byterange, :tvg_id, :tvg_name, :tvg_logo, :group_title

    def initialize(params = {})
      intialize_with_byterange(params)
    end

    def to_s
      date = "#{program_date_time}\n" unless program_date_time.nil?
      "#EXTINF:#{duration} #{iptv_attributes},#{comment}#{byterange_format}\n" \
        "#{date}#{segment}"
    end

    private

    def byterange_format
      return if byterange.nil?
      "\n#EXT-X-BYTERANGE:#{byterange}"
    end

    def iptv_attributes
      [tvg_id_format,
       tvg_logo_format,
       tvg_name_format,
       group_title_format].compact.join(' ')
    end

    def tvg_id_format
      return if tvg_id.nil?
      "tvg-id=\"#{tvg_id}\""
    end

    def tvg_logo_format
      return if tvg_logo.nil?
      "tvg-logo=\"#{tvg_logo}\""
    end

    def tvg_name_format
      return if tvg_name.nil?
      "tvg-name=\"#{tvg_name}\""
    end

    def group_title_format
      return if group_title.nil?
      "group-title=\"#{group_title}\""
    end
  end
end
