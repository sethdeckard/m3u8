require 'spec_helper'

describe M3u8::MediaItem do
  it 'should provide m3u8 format representation' do
    hash = { type: 'AUDIO', group: 'audio-lo', language: 'fre',
             name: 'Francais', auto: true, default: false,
             uri: 'frelo/prog_index.m3u8' }
    item = M3u8::MediaItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-lo",LANGUAGE="fre",' \
               'NAME="Francais",AUTOSELECT=YES,DEFAULT=NO,' \
               'URI="frelo/prog_index.m3u8"'
    expect(output).to eq expected

    hash = { type: 'AUDIO', group: 'audio-lo', language: 'fre',
             assoc_language: 'spoken', name: 'Francais', auto: true,
             default: false, forced: true, uri: 'frelo/prog_index.m3u8' }
    item = M3u8::MediaItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-lo",LANGUAGE="fre",' \
               'ASSOC-LANGUAGE="spoken",NAME="Francais",AUTOSELECT=YES,' \
               'DEFAULT=NO,URI="frelo/prog_index.m3u8",FORCED=YES'
    expect(output).to eq expected
  end
end
