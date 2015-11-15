require 'spec_helper'

describe M3u8::KeyItem do
  it 'should initialize with hash' do
    hash = { method: 'AES-128', uri: 'http://test.key',
             iv: 'D512BBF', key_format: 'identity',
             key_format_versions: '1/3' }
    item = M3u8::KeyItem.new(hash)
    expect(item.method).to eq 'AES-128'
    expect(item.uri).to eq 'http://test.key'
    expect(item.iv).to eq 'D512BBF'
    expect(item.key_format).to eq 'identity'
    expect(item.key_format_versions).to eq '1/3'
  end

  it 'should provide m3u8 format representation' do
    hash = { method: 'AES-128', uri: 'http://test.key',
             iv: 'D512BBF', key_format: 'identity',
             key_format_versions: '1/3' }
    item = M3u8::KeyItem.new(hash)
    expected = %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key",) +
               %(IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")
    expect(item.to_s).to eq expected

    hash = { method: 'AES-128', uri: 'http://test.key' }
    item = M3u8::KeyItem.new(hash)
    expected = %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key")
    expect(item.to_s).to eq expected

    hash = { method: 'NONE' }
    item = M3u8::KeyItem.new(hash)
    expected = '#EXT-X-KEY:METHOD=NONE'
    expect(item.to_s).to eq expected
  end

  it 'should parse m3u8 format into instance' do
    format = %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key",) +
             %(IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")
    item = M3u8::KeyItem.parse format
    expect(item.method).to eq 'AES-128'
    expect(item.uri).to eq 'http://test.key'
    expect(item.iv).to eq 'D512BBF'
    expect(item.key_format).to eq 'identity'
    expect(item.key_format_versions).to eq '1/3'
  end
end
