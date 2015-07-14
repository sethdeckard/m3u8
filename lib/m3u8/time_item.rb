module M3u8
  # TimeItem represents EXT-X-PROGRAM-DATE-TIME
  class TimeItem
    extend M3u8
    attr_accessor :time

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      time = text.gsub('#EXT-X-PROGRAM-DATE-TIME:', '')
      options = { time: Time.parse(time) }
      TimeItem.new options
    end

    def to_s
      %(#EXT-X-PROGRAM-DATE-TIME:#{time_format})
    end

    private

    def time_format
      return time if time.is_a?(String)
      time.iso8601
    end
  end
end
