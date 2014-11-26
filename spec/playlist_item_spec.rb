require 'spec_helper'

describe M3u8::PlaylistItem do
  it 'should initialize with hash' do
    hash = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
             bitrate: 540, playlist: 'test.url' }
    item = M3u8::PlaylistItem.new(hash)
    expect(item.program_id).to eq 1
    expect(item.width).to eq 1920
    expect(item.height).to eq 1080
    expect(item.resolution).to eq '1920x1080'
    expect(item.codecs).to eq 'avc'
    expect(item.bitrate).to eq 540
    expect(item.playlist).to eq 'test.url'
  end

  it 'should provide m3u8 format representation' do
    hash = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
             bitrate: 540, playlist: 'test.url' }
    item = M3u8::PlaylistItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080,' +
               %(CODECS="avc",BANDWIDTH=540\ntest.url)
    expect(output).to eq expected

    hash = { program_id: 1, codecs: 'avc', bitrate: 540, playlist: 'test.url' }
    item = M3u8::PlaylistItem.new(hash)
    output = item.to_s
    expected = '#EXT-X-STREAM-INF:PROGRAM-ID=1,' +
               %(CODECS="avc",BANDWIDTH=540\ntest.url)
    expect(output).to eq expected
  end

  it 'should generate codecs string' do
    item = M3u8::PlaylistItem.new
    expect(item.codecs).to be_nil

    item = M3u8::PlaylistItem.new audio: 'aac-lc'
    expect(item.codecs).to eq 'mp4a.40.2'

    item = M3u8::PlaylistItem.new audio: 'AAC-LC'
    expect(item.codecs).to eq 'mp4a.40.2'

    item = M3u8::PlaylistItem.new audio: 'he-aac'
    expect(item.codecs).to eq 'mp4a.40.5'

    item = M3u8::PlaylistItem.new audio: 'HE-AAC'
    expect(item.codecs).to eq 'mp4a.40.5'

    item = M3u8::PlaylistItem.new audio: 'he-acc1'
    expect(item.codecs).to be_nil

    item = M3u8::PlaylistItem.new audio: 'mp3'
    expect(item.codecs).to eq 'mp4a.40.34'

    item = M3u8::PlaylistItem.new audio: 'MP3'
    expect(item.codecs).to eq 'mp4a.40.34'

    options = { profile: 'baseline', level: 3.0 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.66.30'

    options = { profile: 'baseline', level: 3.0, audio: 'aac-lc' }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.66.30,mp4a.40.2'

    options = { profile: 'baseline', level: 3.0, audio: 'mp3' }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.66.30,mp4a.40.34'

    options = { profile: 'baseline', level: 3.1 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.42001f'

    options = { profile: 'baseline', level: 3.1, audio: 'he-aac' }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.42001f,mp4a.40.5'

    options = { profile: 'main', level: 3.0 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.77.30'

    options = { profile: 'main', level: 3.0, audio: 'aac-lc' }
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
end
