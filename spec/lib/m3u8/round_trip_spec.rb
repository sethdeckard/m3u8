# frozen_string_literal: true

require 'spec_helper'

describe 'Round-trip serialization' do
  def read_fixture(name)
    File.read("spec/fixtures/#{name}")
  end

  def parse(text)
    M3u8::Playlist.read(text)
  end

  context 'exact string round-trip (canonical fixtures)' do
    %w[
      event_playlist.m3u8
      daterange_playlist.m3u8
      master_full.m3u8
      encrypted_discontinuity.m3u8
      ll_hls_advanced.m3u8
    ].each do |fixture|
      it "round-trips #{fixture}" do
        text = read_fixture(fixture)
        expect(parse(text).to_s).to eq(text)
      end
    end
  end

  context 'semantic round-trip (non-canonical fixtures)' do
    it 'round-trips master.m3u8' do
      text = read_fixture('master.m3u8')
      first = parse(text)
      second = parse(first.to_s)

      expect(second.master?).to be true
      expect(second.items.size).to eq(first.items.size)
      expect(second.independent_segments).to eq(true)

      item = second.items[2]
      expect(item).to be_a(M3u8::PlaylistItem)
      expect(item.bandwidth).to eq(5_042_000)
      expect(item.codecs).to eq('avc1.640028,mp4a.40.2')
    end

    it 'round-trips playlist.m3u8' do
      text = read_fixture('playlist.m3u8')
      first = parse(text)
      second = parse(first.to_s)

      expect(second.master?).to be false
      expect(second.items.size).to eq(first.items.size)
      expect(second.version).to eq(4)
      expect(second.sequence).to eq(1)
      expect(second.type).to eq('VOD')
    end

    it 'round-trips master_v13.m3u8' do
      text = read_fixture('master_v13.m3u8')
      first = parse(text)
      second = parse(first.to_s)

      expect(second.version).to eq(13)
      item = second.items[1]
      expect(item).to be_a(M3u8::PlaylistItem)
      expect(item.stable_variant_id).to eq('hd-1080')
      expect(item.video_range).to eq('SDR')
      expect(item.pathway_id).to eq('CDN-A')
      expect(item.score).to eq(12.5)
      expect(item.supplemental_codecs)
        .to eq('dvh1.05.06/db4g')
    end

    it 'round-trips content_steering.m3u8' do
      text = read_fixture('content_steering.m3u8')
      first = parse(text)
      second = parse(first.to_s)

      expect(second.items.size).to eq(first.items.size)
      defines = second.items.select do |i|
        i.is_a?(M3u8::DefineItem)
      end
      expect(defines.size).to eq(2)

      steering = second.items.find do |i|
        i.is_a?(M3u8::ContentSteeringItem)
      end
      expect(steering.server_uri)
        .to eq('https://example.com/steering')
      expect(steering.pathway_id).to eq('CDN-A')
    end

    it 'round-trips ll_hls_playlist.m3u8' do
      text = read_fixture('ll_hls_playlist.m3u8')
      first = parse(text)
      second = parse(first.to_s)

      expect(second.server_control.can_skip_until)
        .to eq(24.0)
      expect(second.part_inf.part_target).to eq(0.5)
      expect(second.items.size).to eq(first.items.size)
    end

    it 'round-trips variant_audio.m3u8' do
      text = read_fixture('variant_audio.m3u8')
      first = parse(text)
      second = parse(first.to_s)

      expect(second.items.size).to eq(first.items.size)
      media = second.items.select do |i|
        i.is_a?(M3u8::MediaItem)
      end
      expect(media.size).to eq(6)
      expect(media.first.group_id).to eq('audio-lo')
    end

    it 'round-trips variant_angles.m3u8' do
      text = read_fixture('variant_angles.m3u8')
      first = parse(text)
      second = parse(first.to_s)

      expect(second.items.size).to eq(first.items.size)
      media = second.items.select do |i|
        i.is_a?(M3u8::MediaItem)
      end
      expect(media.size).to eq(9)
      types = media.map(&:type).uniq.sort
      expect(types).to eq(%w[AUDIO CLOSED-CAPTIONS
                             SUBTITLES VIDEO])
    end

    it 'round-trips gap_playlist.m3u8' do
      text = read_fixture('gap_playlist.m3u8')
      first = parse(text)
      second = parse(first.to_s)

      expect(second.master?).to be false
      expect(second.items.size).to eq(first.items.size)

      item = second.items[0]
      expect(item).to be_a(M3u8::BitrateItem)
      expect(item.bitrate).to eq(128)

      item = second.items[2]
      expect(item).to be_a(M3u8::GapItem)
    end

    it 'round-trips session_data.m3u8' do
      text = read_fixture('session_data.m3u8')
      first = parse(text)
      second = parse(first.to_s)

      expect(second.items.size).to eq(first.items.size)
      item = second.items[0]
      expect(item).to be_a(M3u8::SessionDataItem)
      expect(item.data_id).to eq('com.example.lyrics')
    end
  end
end
