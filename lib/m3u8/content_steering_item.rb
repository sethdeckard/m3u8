# frozen_string_literal: true

module M3u8
  # ContentSteeringItem represents an EXT-X-CONTENT-STEERING tag which
  # indicates a Content Steering Manifest for dynamic pathway selection.
  class ContentSteeringItem
    extend M3u8

    attr_accessor :server_uri, :pathway_id

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.parse(text)
      attributes = parse_attributes(text)
      ContentSteeringItem.new(
        server_uri: attributes['SERVER-URI'],
        pathway_id: attributes['PATHWAY-ID']
      )
    end

    def to_s
      "#EXT-X-CONTENT-STEERING:#{formatted_attributes}"
    end

    private

    def formatted_attributes
      [server_uri_format,
       pathway_id_format].compact.join(',')
    end

    def server_uri_format
      %(SERVER-URI="#{server_uri}")
    end

    def pathway_id_format
      return if pathway_id.nil?

      %(PATHWAY-ID="#{pathway_id}")
    end
  end
end
