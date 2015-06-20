require 'spec_helper'

describe M3u8::PlaylistItem do
  it 'should initialize with hash' do
    hash = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
             bandwidth: 540, uri: 'test.url' }
    item = M3u8::PlaylistItem.new(hash)
    expect(item.program_id).to eq 1
    expect(item.width).to eq 1920
    expect(item.height).to eq 1080
    expect(item.resolution).to eq '1920x1080'
    expect(item.codecs).to eq 'avc'
    expect(item.bandwidth).to eq 540
    expect(item.uri).to eq 'test.url'
    expect(item.iframe).to be false
  end

  it 'should parse m3u8 text into instance' do
    format = %(#EXT-X-STREAM-INF:CODECS="avc",BANDWIDTH=540,) +
             %(PROGRAM-ID=1,RESOLUTION=1920x1080,) +
             %(AVERAGE-BANDWIDTH=550,AUDIO="test",VIDEO="test2",) +
             %(SUBTITLES="subs",CLOSED-CAPTIONS="caps",URI="test.url")
    item = M3u8::PlaylistItem.parse(format)
    expect(item.program_id).to eq '1'
    expect(item.codecs).to eq 'avc'
    expect(item.bandwidth).to eq 540
    expect(item.average_bandwidth).to eq 550
    expect(item.width).to eq 1920
    expect(item.height).to eq 1080
    expect(item.audio).to eq 'test'
    expect(item.video).to eq 'test2'
    expect(item.subtitles).to eq 'subs'
    expect(item.closed_captions).to eq 'caps'
    expect(item.uri).to eq 'test.url'

    format = %(#EXT-X-STREAM-INF:CODECS="avc",BANDWIDTH=540,) +
             %(PROGRAM-ID=1,AUDIO="test",VIDEO="test2",) +
             %(SUBTITLES="subs",CLOSED-CAPTIONS="caps",URI="test.url")
    item = M3u8::PlaylistItem.parse(format)
    expect(item.program_id).to eq '1'
    expect(item.codecs).to eq 'avc'
    expect(item.bandwidth).to eq 540
    expect(item.average_bandwidth).to be_nil
    expect(item.width).to be_nil
    expect(item.height).to be_nil
    expect(item.audio).to eq 'test'
    expect(item.video).to eq 'test2'
    expect(item.subtitles).to eq 'subs'
    expect(item.closed_captions).to eq 'caps'
    expect(item.uri).to eq 'test.url'
  end

  it 'should provide m3u8 format representation' do
    hash = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
             bandwidth: 540, uri: 'test.url' }
    item = M3u8::PlaylistItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080,' +
               %(CODECS="avc",BANDWIDTH=540\ntest.url)
    expect(output).to eq expected

    hash = { program_id: 1, codecs: 'avc', bandwidth: 540,
             uri: 'test.url' }
    item = M3u8::PlaylistItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-STREAM-INF:PROGRAM-ID=1,' +
               %(CODECS="avc",BANDWIDTH=540\ntest.url)
    expect(output).to eq expected

    hash = { codecs: 'avc', bandwidth: 540, uri: 'test.url', audio: 'test',
             video: 'test2', average_bandwidth: 550, subtitles: 'subs',
             closed_captions: 'caps' }
    item = M3u8::PlaylistItem.new(hash)
    output = item.to_s
    expected = %(#EXT-X-STREAM-INF:CODECS="avc",BANDWIDTH=540,) +
               %(AVERAGE-BANDWIDTH=550,AUDIO="test",VIDEO="test2",) +
               %(SUBTITLES="subs",CLOSED-CAPTIONS="caps"\ntest.url)
    expect(output).to eq expected
  end

  it 'should provided m3u8 format with I-Frame option' do
    hash = { codecs: 'avc', bandwidth: 540, uri: 'test.url', iframe: true,
             video: 'test2', average_bandwidth: 550 }
    item = M3u8::PlaylistItem.new(hash)
    output = item.to_s
    expected = %(#EXT-X-I-FRAME-STREAM-INF:CODECS="avc",BANDWIDTH=540,) +
               %(AVERAGE-BANDWIDTH=550,VIDEO="test2",URI="test.url")
    expect(output).to eq expected
  end

  it 'should generate codecs string' do
    item = M3u8::PlaylistItem.new
    expect(item.codecs).to be_nil

    item = M3u8::PlaylistItem.new codecs: 'test'
    expect(item.codecs).to eq 'test'

    item = M3u8::PlaylistItem.new audio_codec: 'aac-lc'
    expect(item.codecs).to eq 'mp4a.40.2'

    item = M3u8::PlaylistItem.new audio_codec: 'AAC-LC'
    expect(item.codecs).to eq 'mp4a.40.2'

    item = M3u8::PlaylistItem.new audio_codec: 'he-aac'
    expect(item.codecs).to eq 'mp4a.40.5'

    item = M3u8::PlaylistItem.new audio_codec: 'HE-AAC'
    expect(item.codecs).to eq 'mp4a.40.5'

    item = M3u8::PlaylistItem.new audio_codec: 'he-acc1'
    expect(item.codecs).to be_nil

    item = M3u8::PlaylistItem.new audio_codec: 'mp3'
    expect(item.codecs).to eq 'mp4a.40.34'

    item = M3u8::PlaylistItem.new audio_codec: 'MP3'
    expect(item.codecs).to eq 'mp4a.40.34'

    options = { profile: 'baseline', level: 3.0 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.66.30'

    options = { profile: 'baseline', level: 3.0, audio_codec: 'aac-lc' }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.66.30,mp4a.40.2'

    options = { profile: 'baseline', level: 3.0, audio_codec: 'mp3' }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.66.30,mp4a.40.34'

    options = { profile: 'baseline', level: 3.1 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.42001f'

    options = { profile: 'baseline', level: 3.1, audio_codec: 'he-aac' }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.42001f,mp4a.40.5'

    options = { profile: 'main', level: 3.0 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.77.30'

    options = { profile: 'main', level: 3.0, audio_codec: 'aac-lc' }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.77.30,mp4a.40.2'

    options = { profile: 'main', level: 3.1 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.4d001f'

    options = { profile: 'main', level: 4.0 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.4d0028'

    options = { profile: 'high', level: 3.1 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.64001f'

    options = { profile: 'high', level: 4.0 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.640028'

    options = { profile: 'high', level: 4.1 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.640028'
  end

  it 'should raise error if codecs are missing' do
    params = { program_id: 1, bandwidth: 540, uri: 'test.url' }
    item = M3u8::PlaylistItem.new params
    message = 'Audio or video codec info should be provided.'
    expect { item.to_s }.to raise_error(M3u8::MissingCodecError, message)
  end
end
