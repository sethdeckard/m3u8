# frozen_string_literal: true

require 'spec_helper'

describe M3u8::DefineItem do
  describe '.new' do
    it 'assigns attributes from options' do
      item = described_class.new(name: 'base_url',
                                 value: 'http://example.com')
      expect(item.name).to eq('base_url')
      expect(item.value).to eq('http://example.com')
    end
  end

  describe '.parse' do
    it 'parses NAME/VALUE define' do
      tag = '#EXT-X-DEFINE:NAME="base_url",VALUE="http://example.com"'
      item = described_class.parse(tag)
      expect(item.name).to eq('base_url')
      expect(item.value).to eq('http://example.com')
      expect(item.import).to be_nil
      expect(item.queryparam).to be_nil
    end

    it 'parses IMPORT define' do
      tag = '#EXT-X-DEFINE:IMPORT="base_url"'
      item = described_class.parse(tag)
      expect(item.import).to eq('base_url')
      expect(item.name).to be_nil
    end

    it 'parses QUERYPARAM define' do
      tag = '#EXT-X-DEFINE:QUERYPARAM="token"'
      item = described_class.parse(tag)
      expect(item.queryparam).to eq('token')
      expect(item.name).to be_nil
    end
  end

  describe '#to_s' do
    it 'returns NAME/VALUE format' do
      item = described_class.new(name: 'base_url',
                                 value: 'http://example.com')
      expected = '#EXT-X-DEFINE:NAME="base_url",' \
                 'VALUE="http://example.com"'
      expect(item.to_s).to eq(expected)
    end

    it 'returns IMPORT format' do
      item = described_class.new(import: 'base_url')
      expect(item.to_s).to eq('#EXT-X-DEFINE:IMPORT="base_url"')
    end

    it 'returns QUERYPARAM format' do
      item = described_class.new(queryparam: 'token')
      expect(item.to_s).to eq('#EXT-X-DEFINE:QUERYPARAM="token"')
    end
  end
end
