# frozen_string_literal: true

module M3u8
  # Codec lookup tables for HLS playlist items
  module Codecs
    AUDIO_CODECS = {
      'aac-lc' => 'mp4a.40.2',
      'he-aac' => 'mp4a.40.5',
      'mp3' => 'mp4a.40.34',
      'ac-3' => 'ac-3',
      'ec-3' => 'ec-3',
      'e-ac-3' => 'ec-3',
      'flac' => 'fLaC',
      'opus' => 'Opus'
    }.freeze

    BASELINE_CODECS = {
      3.0 => 'avc1.66.30',
      3.1 => 'avc1.42001f'
    }.freeze

    MAIN_CODECS = {
      3.0 => 'avc1.77.30',
      3.1 => 'avc1.4d001f',
      4.0 => 'avc1.4d0028',
      4.1 => 'avc1.4d0029'
    }.freeze

    HIGH_LEVELS = [3.0, 3.1, 3.2, 4.0, 4.1, 4.2,
                   5.0, 5.1, 5.2].freeze

    HEVC_CODECS = {
      ['hevc-main', 3.1] => 'hvc1.1.6.L93.B0',
      ['hevc-main', 4.0] => 'hvc1.1.6.L120.B0',
      ['hevc-main', 5.0] => 'hvc1.1.6.L150.B0',
      ['hevc-main', 5.1] => 'hvc1.1.6.L153.B0',
      ['hevc-main-10', 3.1] => 'hvc1.2.4.L93.B0',
      ['hevc-main-10', 4.0] => 'hvc1.2.4.L120.B0',
      ['hevc-main-10', 5.0] => 'hvc1.2.4.L150.B0',
      ['hevc-main-10', 5.1] => 'hvc1.2.4.L153.B0'
    }.freeze

    AV1_CODECS = {
      ['av1-main', 3.1] => 'av01.0.04M.08',
      ['av1-main', 4.0] => 'av01.0.08M.08',
      ['av1-main', 5.0] => 'av01.0.12M.08',
      ['av1-main', 5.1] => 'av01.0.13M.08',
      ['av1-high', 3.1] => 'av01.1.04H.10',
      ['av1-high', 4.0] => 'av01.1.08H.10',
      ['av1-high', 5.0] => 'av01.1.12H.10',
      ['av1-high', 5.1] => 'av01.1.13H.10'
    }.freeze

    # Look up the codec string for an audio codec name.
    # @param codec [String, nil] audio codec name
    # @return [String, nil] codec string
    def self.audio_codec(codec)
      return if codec.nil?

      AUDIO_CODECS[codec.downcase]
    end

    # Look up the codec string for a video profile and level.
    # @param profile [String, nil] video profile name
    # @param level [Float, Integer, nil] video level
    # @return [String, nil] codec string
    def self.video_codec(profile, level)
      return if profile.nil? || level.nil?

      level = level.to_f
      name = profile.downcase
      return BASELINE_CODECS[level] if name == 'baseline'
      return MAIN_CODECS[level] if name == 'main'
      return high_codec_string(level) if name == 'high'
      return HEVC_CODECS[[profile, level]] if name.start_with?('hevc-')

      AV1_CODECS[[profile, level]] if name.start_with?('av1-')
    end

    def self.high_codec_string(level)
      return nil unless HIGH_LEVELS.include?(level)

      hex = level.to_s.sub('.', '').to_i.to_s(16)
      "avc1.6400#{hex}"
    end

    private_class_method :high_codec_string
  end
end
