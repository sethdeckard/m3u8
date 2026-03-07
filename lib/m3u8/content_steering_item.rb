# frozen_string_literal: true

module M3u8
  # ContentSteeringItem represents an EXT-X-CONTENT-STEERING tag which
  # indicates a Content Steering Manifest for dynamic pathway selection.
  class ContentSteeringItem
    extend M3u8
    include AttributeFormatter

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
      [quoted_format('SERVER-URI', server_uri),
       quoted_format('PATHWAY-ID', pathway_id)].compact.join(',')
    end
  end
end
