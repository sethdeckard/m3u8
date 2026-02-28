# frozen_string_literal: true

require 'optparse'
require_relative 'cli/inspect_command'
require_relative 'cli/validate_command'

module M3u8
  # CLI provides a command-line interface for inspecting and validating
  # m3u8 playlists
  class CLI
    COMMANDS = %w[inspect validate].freeze

    def self.run(argv, stdin, stdout, stderr)
      new(argv, stdin, stdout, stderr).run
    end

    def initialize(argv, stdin, stdout, stderr)
      @argv = argv.dup
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
    end

    def run
      parse_global_options
      dispatch
    rescue OptionParser::InvalidOption => e
      @stderr.puts e.message
      2
    end

    private

    def parse_global_options
      @parser = OptionParser.new do |opts|
        opts.banner = 'Usage: m3u8 <command> [options] [file]'
        opts.separator ''
        opts.separator 'Commands:'
        opts.separator '  inspect    Show playlist metadata'
        opts.separator '  validate   Check playlist validity'
        opts.separator ''
        opts.on('-v', '--version', 'Show version') do
          @stdout.puts M3u8::VERSION
          throw :exit, 0
        end
        opts.on('-h', '--help', 'Show help') do
          @stdout.puts opts
          throw :exit, 0
        end
      end

      @exit_code = catch(:exit) do
        @parser.order!(@argv)
        nil
      end
    end

    def dispatch
      return @exit_code if @exit_code

      command = @argv.shift
      return usage_error if command.nil?
      return usage_error("unknown command: #{command}") \
        unless COMMANDS.include?(command)

      input = resolve_input
      return 2 unless input

      playlist = parse_playlist(input)
      return 2 unless playlist

      execute_command(command, playlist)
    end

    def execute_command(command, playlist)
      case command
      when 'inspect'
        InspectCommand.new(playlist, @stdout).run
      when 'validate'
        ValidateCommand.new(playlist, @stdout).run
      end
    end

    def resolve_input
      file = @argv.shift
      if file
        read_file(file)
      elsif !@stdin.tty?
        @stdin.read
      else
        usage_error
        nil
      end
    end

    def read_file(path)
      File.read(path)
    rescue Errno::ENOENT
      @stderr.puts "no such file: #{path}"
      nil
    end

    def parse_playlist(input)
      Playlist.read(input)
    rescue StandardError => e
      @stderr.puts "parse error: #{e.message}"
      nil
    end

    def usage_error(message = nil)
      @stderr.puts message if message
      @stderr.puts @parser.to_s
      2
    end
  end
end
