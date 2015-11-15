require 'spec_helper'

describe M3u8::SessionDataItem do
  it 'should initialize with hash' do
    hash = { data_id: 'com.test.movie.title', value: 'Test',
             uri: 'http://test', language: 'en' }
    item = M3u8::SessionDataItem.new(hash)
    expect(item.data_id).to eq 'com.test.movie.title'
    expect(item.value).to eq 'Test'
    expect(item.uri).to eq 'http://test'
    expect(item.language).to eq 'en'
  end

  it 'should provide m3u8 format representation' do
    hash = { data_id: 'com.test.movie.title', value: 'Test',
             language: 'en' }
    item = M3u8::SessionDataItem.new(hash)
    output = item.to_s
    expected = %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",) +
               %(VALUE="Test",LANGUAGE="en")
    expect(output).to eq expected

    hash = { data_id: 'com.test.movie.title', uri: 'http://test',
             language: 'en' }
    item = M3u8::SessionDataItem.new(hash)
    output = item.to_s
    expected = %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",) +
               %(URI="http://test",LANGUAGE="en")
    expect(output).to eq expected
  end

  it 'should parse m3u8 format into instance' do
    format = %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",) +
             %(VALUE="Test",LANGUAGE="en")
    item = M3u8::SessionDataItem.parse format
    expect(item.data_id).to eq 'com.test.movie.title'
    expect(item.value).to eq 'Test'
    expect(item.uri).to be_nil
    expect(item.language).to eq 'en'

    format = %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",) +
             %(URI="http://test",LANGUAGE="en")
    item = M3u8::SessionDataItem.parse format
    expect(item.data_id).to eq 'com.test.movie.title'
    expect(item.value).to be_nil
    expect(item.uri).to eq 'http://test'
    expect(item.language).to eq 'en'
  end
end
