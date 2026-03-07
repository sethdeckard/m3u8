# frozen_string_literal: true

module M3u8
  # ContentSteeringItem represents an EXT-X-CONTENT-STEERING tag which
  # indicates a Content Steering Manifest for dynamic pathway selection.
  class ContentSteeringItem
    extend M3u8
    include AttributeFormatter

    # @return [String, nil] steering manifest server URI
    # @return [String, nil] default pathway ID
    attr_accessor :server_uri, :pathway_id

    # @param params [Hash] attribute key-value pairs
    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Parse an EXT-X-CONTENT-STEERING tag.
    # @param text [String] raw tag line
    # @return [ContentSteeringItem]
    def self.parse(text)
      attributes = parse_attributes(text)
      ContentSteeringItem.new(
        server_uri: attributes['SERVER-URI'],
        pathway_id: attributes['PATHWAY-ID']
      )
    end

    # Render as an m3u8 EXT-X-CONTENT-STEERING tag.
    # @return [String]
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
