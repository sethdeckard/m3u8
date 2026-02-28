# frozen_string_literal: true

require 'spec_helper'

describe M3u8::CLI::ValidateCommand do
  let(:stdout) { StringIO.new }

  describe '#run' do
    context 'when playlist is valid' do
      it 'prints Valid and returns 0' do
        playlist = M3u8::Playlist.read(
          File.read('spec/fixtures/master.m3u8')
        )
        code = described_class.new(playlist, stdout).run
        expect(code).to eq(0)
        expect(stdout.string.strip).to eq('Valid')
      end
    end

    context 'when playlist is invalid' do
      it 'prints Invalid and returns 1' do
        playlist = M3u8::Playlist.new
        playlist.items << M3u8::PlaylistItem.new(
          bandwidth: 540, uri: 'test.url'
        )
        playlist.items << M3u8::SegmentItem.new(
          duration: 10.0, segment: 'test.ts'
        )
        code = described_class.new(playlist, stdout).run
        expect(code).to eq(1)
        expect(stdout.string.strip).to include('Invalid')
      end
    end
  end
end
