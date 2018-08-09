# frozen_string_literal: true
require 'spec_helper'

describe M3u8::PlaylistItem do
  describe '.new' do
    it 'assigns attributes from options' do
      options = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
                  bandwidth: 540, audio_codec: 'mp3', level: '2',
                  profile: 'baseline', video: 'test_video', audio: 'test_a',
                  uri: 'test.url', average_bandwidth: 500, subtitles: 'subs',
                  closed_captions: 'cc', iframe: true, frame_rate: 24.6,
                  name: 'test_name', hdcp_level: 'TYPE-0' }
      item = described_class.new(options)

      expect(item.program_id).to eq(1)
      expect(item.width).to eq(1920)
      expect(item.height).to eq(1080)
      expect(item.resolution).to eq('1920x1080')
      expect(item.codecs).to eq('avc')
      expect(item.bandwidth).to eq(540)
      expect(item.audio_codec).to eq('mp3')
      expect(item.level).to eq('2')
      expect(item.profile).to eq('baseline')
      expect(item.video).to eq('test_video')
      expect(item.audio).to eq('test_a')
      expect(item.uri).to eq('test.url')
      expect(item.average_bandwidth).to eq(500)
      expect(item.subtitles).to eq('subs')
      expect(item.closed_captions).to eq('cc')
      expect(item.iframe).to be true
      expect(item.frame_rate).to eq(24.6)
      expect(item.name).to eq('test_name')
      expect(item.hdcp_level).to eq('TYPE-0')
    end
  end

  describe '.parse' do
    it 'returns new instance from parsed tag' do
      tag = %(#EXT-X-STREAM-INF:CODECS="avc",BANDWIDTH=540,) +
            %(PROGRAM-ID=1,RESOLUTION=1920x1080,FRAME-RATE=23.976,) +
            %(AVERAGE-BANDWIDTH=550,AUDIO="test",VIDEO="test2",) +
            %(SUBTITLES="subs",CLOSED-CAPTIONS="caps",URI="test.url",) +
            %(NAME="1080p",HDCP-LEVEL=TYPE-0)
      expect_any_instance_of(described_class).to receive(:parse).with(tag)
      item = described_class.parse(tag)
      expect(item).to be_a(described_class)
    end
  end

  describe '#parse' do
    it 'assigns values from parsed tag' do
      input = %(#EXT-X-STREAM-INF:CODECS="avc",BANDWIDTH=540,) +
              %(PROGRAM-ID=1,RESOLUTION=1920x1080,FRAME-RATE=23.976,) +
              %(AVERAGE-BANDWIDTH=550,AUDIO="test",VIDEO="test2",) +
              %(SUBTITLES="subs",CLOSED-CAPTIONS="caps",URI="test.url",) +
              %(NAME="1080p",HDCP-LEVEL=TYPE-0)
      item = M3u8::PlaylistItem.parse(input)
      expect(item.program_id).to eq '1'
      expect(item.codecs).to eq 'avc'
      expect(item.bandwidth).to eq 540
      expect(item.average_bandwidth).to eq 550
      expect(item.width).to eq 1920
      expect(item.height).to eq 1080
      expect(item.frame_rate).to eq BigDecimal('23.976')
      expect(item.audio).to eq 'test'
      expect(item.video).to eq 'test2'
      expect(item.subtitles).to eq 'subs'
      expect(item.closed_captions).to eq 'caps'
      expect(item.uri).to eq 'test.url'
      expect(item.name).to eq '1080p'
      expect(item.iframe).to be false
      expect(item.hdcp_level).to eq('TYPE-0')
    end
  end

  describe '#to_s' do
    context 'when codecs is missing' do
      it 'does not specify CODECS' do
        params = { bandwidth: 540, uri: 'test.url' }
        item = M3u8::PlaylistItem.new params
        expect(item.to_s).not_to include('CODECS')
      end
    end

    context 'when level is not recognized' do
      it 'does not specify CODECS' do
        params = { bandwidth: 540, uri: 'test.url', level: 9001 }
        item = M3u8::PlaylistItem.new params
        expect(item.to_s).not_to include('CODECS')
      end
    end

    context 'when profile is not recognized' do
      it 'does not specify CODECS' do
        params = { bandwidth: 540, uri: 'test.url', profile: 'best' }
        item = M3u8::PlaylistItem.new params
        expect(item.to_s).not_to include('CODECS')
      end
    end

    context 'when profile and level are not recognized' do
      it 'does not specify CODECS' do
        params = { bandwidth: 540, uri: 'test.url', profile: 'best',
                   level: 9001 }
        item = M3u8::PlaylistItem.new params
        expect(item.to_s).not_to include('CODECS')
      end

      context 'when audio codec is recognized' do
        it 'does not specify CODECS' do
          params = { bandwidth: 540, uri: 'test.url', profile: 'best',
                     level: 9001, audio_codec: 'aac-lc' }
          item = M3u8::PlaylistItem.new params
          expect(item.to_s).not_to include('CODECS')
        end
      end
    end

    context 'when profile and level are not set' do
      context 'when audio codec is recognized' do
        it 'specifies CODECS with audio codec' do
          params = { bandwidth: 540, uri: 'test.url', audio_codec: 'aac-lc' }
          item = M3u8::PlaylistItem.new params
          expect(item.to_s).to include('CODECS="mp4a.40.2"')
        end
      end
    end

    context 'when profile and level are recognized' do
      context 'when audio codec is not recognized' do
        it 'does not specify CODECS' do
          params = { bandwidth: 540, uri: 'test.url', profile: 'high',
                     level: 4.1, audio_codec: 'fuzzy' }
          item = M3u8::PlaylistItem.new params
          expect(item.to_s).not_to include('CODECS')
        end
      end

      context 'when audio codec is not set' do
        it 'specifies CODECS with video codec' do
          params = { bandwidth: 540, uri: 'test.url', profile: 'high',
                     level: 4.1 }
          item = M3u8::PlaylistItem.new params
          expect(item.to_s).to include('CODECS="avc1.640029"')
        end
      end

      context 'when audio codec is recognized' do
        it 'specifies CODECS with video codec and audio_codec' do
          params = { bandwidth: 540, uri: 'test.url', profile: 'high',
                     level: 4.1, audio_codec: 'aac-lc' }
          item = M3u8::PlaylistItem.new params
          expect(item.to_s).to include('CODECS="avc1.640029,mp4a.40.2"')
        end
      end
    end

    context 'when only required attributes are present' do
      it 'returns tag' do
        options = { codecs: 'avc', bandwidth: 540,
                    uri: 'test.url' }
        item = described_class.new(options)
        expected = %(#EXT-X-STREAM-INF:CODECS="avc",BANDWIDTH=540) +
                   "\ntest.url"
        expect(item.to_s).to eq(expected)
      end
    end

    context 'when all attributes are present' do
      it 'returns tag' do
        options = { codecs: 'avc', bandwidth: 540, uri: 'test.url',
                    audio: 'test', video: 'test2', average_bandwidth: 500,
                    subtitles: 'subs', frame_rate: 30, closed_captions: 'caps',
                    name: 'SD', hdcp_level: 'TYPE-0', program_id: '1' }
        item = described_class.new(options)
        expected = %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="avc",) +
                   'BANDWIDTH=540,AVERAGE-BANDWIDTH=500,FRAME-RATE=30.000,' \
                   'HDCP-LEVEL=TYPE-0,' +
                   %(AUDIO="test",VIDEO="test2",SUBTITLES="subs",) +
                   %(CLOSED-CAPTIONS="caps",NAME="SD"\ntest.url)
        expect(item.to_s).to eq(expected)
      end
    end

    context 'when closed captions is NONE' do
      it 'returns tag' do
        options = { program_id: 1, width: 1920, height: 1080, codecs: 'avc',
                    bandwidth: 540, uri: 'test.url', closed_captions: 'NONE' }
        item = described_class.new(options)
        expected = '#EXT-X-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080,' +
                   %(CODECS="avc",BANDWIDTH=540,CLOSED-CAPTIONS=NONE\ntest.url)
        expect(item.to_s).to eq(expected)
      end
    end

    context 'when iframe is enabled' do
      it 'returns EXT-X-I-FRAME-STREAM-INF tag' do
        options = { codecs: 'avc', bandwidth: 540, uri: 'test.url',
                    iframe: true, video: 'test2', average_bandwidth: 550 }
        item = described_class.new(options)
        expected = %(#EXT-X-I-FRAME-STREAM-INF:CODECS="avc",BANDWIDTH=540,) +
                   %(AVERAGE-BANDWIDTH=550,VIDEO="test2",URI="test.url")
        expect(item.to_s).to eq(expected)
      end
    end
  end

  it 'generates codecs string' do
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

    options = { profile: 'main', level: 4.1 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.4d0029'

    options = { profile: 'high', level: 3.1 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.64001f'

    options = { profile: 'high', level: 4.0 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.640028'

    options = { profile: 'high', level: 4.1 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.640029'

    options = { profile: 'high', level: 5.1 }
    item = M3u8::PlaylistItem.new options
    expect(item.codecs).to eq 'avc1.640033'
  end
end
