# frozen_string_literal: true

require 'spec_helper'

describe M3u8::MediaItem do
  describe '.new' do
    it 'assigns attributes from options' do
      options = { type: 'AUDIO', group_id: 'audio-lo', language: 'fre',
                  assoc_language: 'spoken', name: 'Francais', autoselect: true,
                  default: false, forced: true, uri: 'frelo/prog_index.m3u8',
                  instream_id: 'SERVICE3', characteristics: 'public.html',
                  channels: '6' }
      item = described_class.new(options)

      expect(item.type).to eq('AUDIO')
      expect(item.group_id).to eq('audio-lo')
      expect(item.language).to eq('fre')
      expect(item.assoc_language).to eq('spoken')
      expect(item.name).to eq('Francais')
      expect(item.autoselect).to be true
      expect(item.default).to be false
      expect(item.uri).to eq('frelo/prog_index.m3u8')
      expect(item.forced).to be true
      expect(item.instream_id).to eq('SERVICE3')
      expect(item.characteristics).to eq('public.html')
      expect(item.channels).to eq('6')
    end

    it 'assigns v13 attributes from options' do
      options = { type: 'AUDIO', group_id: 'aac', name: 'English',
                  stable_rendition_id: 'audio-en', bit_depth: 16,
                  sample_rate: 44_100 }
      item = described_class.new(options)
      expect(item.stable_rendition_id).to eq('audio-en')
      expect(item.bit_depth).to eq(16)
      expect(item.sample_rate).to eq(44_100)
    end
  end

  describe '.parse' do
    it 'returns instance from parsed tag' do
      tag = '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-lo",LANGUAGE="fre",' \
            'ASSOC-LANGUAGE="spoken",NAME="Francais",AUTOSELECT=YES,' \
            'INSTREAM-ID="SERVICE3",CHARACTERISTICS="public.html",' \
            'CHANNELS="6",' +
            %("DEFAULT=NO,URI="frelo/prog_index.m3u8",FORCED=YES\n")
      item = described_class.parse(tag)

      expect(item.type).to eq('AUDIO')
      expect(item.group_id).to eq('audio-lo')
      expect(item.language).to eq('fre')
      expect(item.assoc_language).to eq('spoken')
      expect(item.name).to eq('Francais')
      expect(item.autoselect).to be true
      expect(item.default).to be false
      expect(item.uri).to eq('frelo/prog_index.m3u8')
      expect(item.forced).to be true
      expect(item.instream_id).to eq('SERVICE3')
      expect(item.characteristics).to eq('public.html')
      expect(item.channels).to eq('6')
    end

    it 'parses v13 attributes' do
      tag = '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="aac",' \
            'NAME="English",STABLE-RENDITION-ID="audio-en",' \
            'BIT-DEPTH=16,SAMPLE-RATE=44100'
      item = described_class.parse(tag)
      expect(item.stable_rendition_id).to eq('audio-en')
      expect(item.bit_depth).to eq(16)
      expect(item.sample_rate).to eq(44_100)
    end
  end

  describe '#to_s' do
    context 'when no attributes are assigned' do
      it 'returns default tag text' do
        item = described_class.new
        expected = '#EXT-X-MEDIA:TYPE=,GROUP-ID="",NAME=""'
        expect(item.to_s).to eq(expected)
      end
    end

    context 'when only required attributes are assigned' do
      it 'returns tag text' do
        options = { type: 'AUDIO', group_id: 'audio-lo', name: 'Francais' }
        item = described_class.new(options)
        expected = '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-lo",NAME="Francais"'
        expect(item.to_s).to eq(expected)
      end
    end

    context 'when all attributes are assigned' do
      it 'returns tag text' do
        options = { type: 'AUDIO', group_id: 'audio-lo', language: 'fre',
                    assoc_language: 'spoken', name: 'Francais',
                    autoselect: true, default: false, forced: true,
                    uri: 'frelo/prog_index.m3u8', instream_id: 'SERVICE3',
                    characteristics: 'public.html', channels: '6' }
        item = M3u8::MediaItem.new(options)
        output = item.to_s
        expected = '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-lo",' \
                   'LANGUAGE="fre",ASSOC-LANGUAGE="spoken",' \
                   'NAME="Francais",AUTOSELECT=YES,' \
                   'DEFAULT=NO,URI="frelo/prog_index.m3u8",FORCED=YES,' \
                   'INSTREAM-ID="SERVICE3",CHARACTERISTICS="public.html",' \
                   'CHANNELS="6"'
        expect(output).to eq(expected)
      end
    end

    context 'when v13 attributes are assigned' do
      it 'returns tag text with new attributes' do
        options = { type: 'AUDIO', group_id: 'aac', name: 'English',
                    channels: '2', stable_rendition_id: 'audio-en',
                    bit_depth: 16, sample_rate: 44_100 }
        item = M3u8::MediaItem.new(options)
        output = item.to_s
        expect(output).to include('STABLE-RENDITION-ID="audio-en"')
        expect(output).to include('BIT-DEPTH=16')
        expect(output).to include('SAMPLE-RATE=44100')
      end
    end
  end
end
