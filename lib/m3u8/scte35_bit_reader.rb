# frozen_string_literal: true

module M3u8
  # Reads sub-byte bit fields from binary data for SCTE-35 parsing
  class Scte35BitReader
    def initialize(data)
      @data = data.b
      @byte_pos = 0
      @bit_pos = 0
    end

    def read_bits(count)
      value = 0
      count.times do
        value = (value << 1) | current_bit
        advance_bit
      end
      value
    end

    def read_flag
      read_bits(1) == 1
    end

    def read_bytes(count)
      @data[@byte_pos, count].tap { @byte_pos += count }
    end

    def skip_bits(count)
      count.times { advance_bit }
    end

    def bytes_remaining
      @data.length - @byte_pos - (@bit_pos.positive? ? 1 : 0)
    end

    private

    def current_bit
      (@data.getbyte(@byte_pos) >> (7 - @bit_pos)) & 1
    end

    def advance_bit
      @bit_pos += 1
      return unless @bit_pos >= 8

      @bit_pos = 0
      @byte_pos += 1
    end
  end
end
