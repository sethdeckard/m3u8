# frozen_string_literal: true

require 'spec_helper'

describe M3u8::CLI::InspectCommand do
  let(:stdout) { StringIO.new }

  def inspect_fixture(name)
    playlist = M3u8::Playlist.read(
      File.read("spec/fixtures/#{name}")
    )
    described_class.new(playlist, stdout).run
  end

  describe 'media playlist' do
    it 'displays metadata for a VOD playlist' do
      code = inspect_fixture('playlist.m3u8')
      expect(code).to eq(0)
      lines = stdout.string
      expect(lines).to include('Type:       Media')
      expect(lines).to include('Version:    4')
      expect(lines).to include('Sequence:   1')
      expect(lines).to include('Target:     12')
      expect(lines).to include('Duration:   1371.99s')
      expect(lines).to include('Playlist:   VOD')
      expect(lines).to include('Cache:      No')
      expect(lines).to include('Segments:   138')
      expect(lines).to include('Keys:       0')
      expect(lines).to include('Maps:       0')
    end

    it 'displays metadata for an encrypted playlist' do
      code = inspect_fixture('encrypted.m3u8')
      expect(code).to eq(0)
      lines = stdout.string
      expect(lines).to include('Type:       Media')
      expect(lines).to include('Version:    3')
      expect(lines).to include('Sequence:   7794')
      expect(lines).to include('Target:     15')
      expect(lines).to include('Segments:   4')
      expect(lines).to include('Keys:       2')
      expect(lines).not_to include('Playlist:')
      expect(lines).not_to include('Cache:')
    end

    it 'displays metadata for an LL-HLS playlist' do
      code = inspect_fixture('ll_hls_playlist.m3u8')
      expect(code).to eq(0)
      lines = stdout.string
      expect(lines).to include('Type:       Media')
      expect(lines).to include('Version:    9')
      expect(lines).to include('Segments:   2')
      expect(lines).to include('Maps:       1')
    end
  end
end
