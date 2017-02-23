# frozen_string_literal: true
require 'spec_helper'

describe M3u8::MediaItem do
  it 'should provide m3u8 format representation' do
    hash = { type: 'AUDIO', group_id: 'audio-lo', language: 'fre',
             name: 'Francais', autoselect: true, default: false,
             uri: 'frelo/prog_index.m3u8' }
    item = M3u8::MediaItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-lo",LANGUAGE="fre",' \
               'NAME="Francais",AUTOSELECT=YES,DEFAULT=NO,' \
               'URI="frelo/prog_index.m3u8"'
    expect(output).to eq expected

    hash = { type: 'AUDIO', group_id: 'audio-lo', language: 'fre',
             assoc_language: 'spoken', name: 'Francais', autoselect: true,
             default: false, forced: true, uri: 'frelo/prog_index.m3u8' }
    item = M3u8::MediaItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-lo",LANGUAGE="fre",' \
               'ASSOC-LANGUAGE="spoken",NAME="Francais",AUTOSELECT=YES,' \
               'DEFAULT=NO,URI="frelo/prog_index.m3u8",FORCED=YES'
    expect(output).to eq expected
  end

  it 'should parse m3u8 text into instance' do
    format = '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-lo",LANGUAGE="fre",' \
             'ASSOC-LANGUAGE="spoken",NAME="Francais",AUTOSELECT=YES,' +
             %("DEFAULT=NO,URI="frelo/prog_index.m3u8",FORCED=YES\n")
    item = M3u8::MediaItem.parse format

    expect(item.type).to eq 'AUDIO'
    expect(item.group_id).to eq 'audio-lo'
    expect(item.language).to eq 'fre'
    expect(item.assoc_language).to eq 'spoken'
    expect(item.name).to eq 'Francais'
    expect(item.autoselect).to be true
    expect(item.default).to be false
    expect(item.uri).to eq 'frelo/prog_index.m3u8'
    expect(item.forced).to be true
  end
end
