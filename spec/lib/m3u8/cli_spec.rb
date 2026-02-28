# frozen_string_literal: true

require 'spec_helper'

describe M3u8::CLI do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }
  let(:stdin) { StringIO.new }

  def run(argv)
    described_class.run(argv, stdin, stdout, stderr)
  end

  describe '--version' do
    it 'prints the version and exits 0' do
      expect(run(['--version'])).to eq(0)
      expect(stdout.string.strip).to eq(M3u8::VERSION)
    end
  end

  describe '--help' do
    it 'prints usage and exits 0' do
      expect(run(['--help'])).to eq(0)
      expect(stdout.string).to include('Usage: m3u8')
      expect(stdout.string).to include('inspect')
      expect(stdout.string).to include('validate')
    end
  end

  describe 'no command' do
    it 'prints usage to stderr and exits 2' do
      expect(run([])).to eq(2)
      expect(stderr.string).to include('Usage: m3u8')
    end
  end

  describe 'unknown command' do
    it 'prints error and usage to stderr and exits 2' do
      expect(run(['bogus'])).to eq(2)
      expect(stderr.string).to include('unknown command: bogus')
    end
  end

  describe 'invalid option' do
    it 'prints error to stderr and exits 2' do
      expect(run(['--bogus'])).to eq(2)
      expect(stderr.string).to include('invalid option')
    end
  end

  describe 'file not found' do
    it 'prints error to stderr and exits 2' do
      expect(run(['inspect', 'nonexistent.m3u8'])).to eq(2)
      expect(stderr.string).to include('no such file')
    end
  end

  describe 'file input' do
    it 'reads a playlist from a file for inspect' do
      code = run(['inspect', 'spec/fixtures/master.m3u8'])
      expect(code).to eq(0)
    end

    it 'reads a playlist from a file for validate' do
      code = run(['validate', 'spec/fixtures/master.m3u8'])
      expect(code).to eq(0)
      expect(stdout.string.strip).to eq('Valid')
    end
  end

  describe 'parse error' do
    it 'prints error to stderr and exits 2' do
      stdin = StringIO.new('not a playlist')
      code = described_class.run(
        ['inspect'], stdin, stdout, stderr
      )
      expect(code).to eq(2)
      expect(stderr.string).to include('parse error')
    end
  end

  describe 'stdin input' do
    it 'reads a playlist from stdin' do
      content = File.read('spec/fixtures/master.m3u8')
      stdin = StringIO.new(content)
      code = described_class.run(
        ['inspect'], stdin, stdout, stderr
      )
      expect(code).to eq(0)
    end
  end

  describe 'command with no input on a tty' do
    it 'prints usage to stderr and exits 2' do
      tty = StringIO.new
      allow(tty).to receive(:tty?).and_return(true)
      code = described_class.run(
        ['inspect'], tty, stdout, stderr
      )
      expect(code).to eq(2)
      expect(stderr.string).to include('Usage: m3u8')
    end
  end
end
