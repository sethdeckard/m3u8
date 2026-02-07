[![Gem Version](https://badge.fury.io/rb/m3u8.svg)](http://badge.fury.io/rb/m3u8)
[![CI](https://github.com/sethdeckard/m3u8/actions/workflows/ci.yml/badge.svg)](https://github.com/sethdeckard/m3u8/actions/workflows/ci.yml)
# m3u8

m3u8 provides easy generation and parsing of m3u8 playlists defined in the [HTTP Live Streaming (HLS)](https://datatracker.ietf.org/doc/html/draft-pantos-hls-rfc8216bis) Internet Draft published by Apple.

* Full coverage of [draft-pantos-hls-rfc8216bis-19](https://datatracker.ietf.org/doc/html/draft-pantos-hls-rfc8216bis-19) (Protocol Version 13), including Low-Latency HLS and Content Steering.
* Provides parsing of an m3u8 playlist into an object model from any File, StringIO, or string.
* Provides ability to write playlist to a File or StringIO or expose as string via to_s.
* Distinction between a master and media playlist is handled automatically (single Playlist class).
* Automatic generation of codec strings for H.264, HEVC, AV1, AAC, AC-3, E-AC-3, FLAC, Opus, and MP3.

## Requirements

Ruby 3.0+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'm3u8'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install m3u8

## Usage (creating playlists)

Create a master playlist and add child playlists for adaptive bitrate streaming:

```ruby
require 'm3u8'
playlist = M3u8::Playlist.new
```

Create a new playlist item with options:

```ruby
options = { width: 1920, height: 1080, profile: 'high', level: 4.1,
            audio_codec: 'aac-lc', bandwidth: 540, uri: 'test.url' }
item = M3u8::PlaylistItem.new(options)
playlist.items << item
```

Add alternate audio, camera angles, closed captions and subtitles by creating MediaItem instances and adding them to the Playlist:

```ruby
hash = { type: 'AUDIO', group_id: 'audio-lo', language: 'fre',
         assoc_language: 'spoken', name: 'Francais', autoselect: true,
         default: false, forced: true, uri: 'frelo/prog_index.m3u8' }
item = M3u8::MediaItem.new(hash)
playlist.items << item
```

Add Content Steering for dynamic CDN pathway selection:

```ruby
item = M3u8::ContentSteeringItem.new(
  server_uri: 'https://example.com/steering',
  pathway_id: 'CDN-A'
)
playlist.items << item
```

Add variable definitions:

```ruby
item = M3u8::DefineItem.new(name: 'base', value: 'https://example.com')
playlist.items << item
```

Add a session-level encryption key (master playlists):

```ruby
item = M3u8::SessionKeyItem.new(
  method: 'AES-128', uri: 'https://example.com/key.bin'
)
playlist.items << item
```

Add session-level data (master playlists):

```ruby
item = M3u8::SessionDataItem.new(
  data_id: 'com.example.title', value: 'My Video',
  language: 'en'
)
playlist.items << item
```

Create a standard playlist and add MPEG-TS segments via SegmentItem:

```ruby
options = { version: 1, cache: false, target: 12, sequence: 1 }
playlist = M3u8::Playlist.new(options)

item = M3u8::SegmentItem.new(duration: 11, segment: 'test.ts')
playlist.items << item
```

### Media segment tags

Add an encryption key for subsequent segments:

```ruby
item = M3u8::KeyItem.new(
  method: 'AES-128',
  uri: 'https://example.com/key.bin',
  iv: '0x1234567890abcdef1234567890abcdef'
)
playlist.items << item
```

Specify an initialization segment (e.g. fMP4 header):

```ruby
item = M3u8::MapItem.new(
  uri: 'init.mp4', byterange: { length: 812, start: 0 }
)
playlist.items << item
```

Insert a timed metadata date range:

```ruby
item = M3u8::DateRangeItem.new(
  id: 'ad-break-1', start_date: '2024-06-01T12:00:00Z',
  planned_duration: 30.0,
  client_attributes: { 'X-AD-ID' => '"foo"' }
)
playlist.items << item
```

Signal an encoding discontinuity:

```ruby
playlist.items << M3u8::DiscontinuityItem.new
```

Attach a program date/time to the next segment:

```ruby
item = M3u8::TimeItem.new(time: Time.iso8601('2024-06-01T12:00:00Z'))
playlist.items << item
```

Mark a gap in segment availability:

```ruby
playlist.items << M3u8::GapItem.new
```

Add a bitrate hint for upcoming segments:

```ruby
item = M3u8::BitrateItem.new(bitrate: 1500)
playlist.items << item
```

### Low-Latency HLS

Create an LL-HLS playlist with server control, partial segments, and preload hints:

```ruby
server_control = M3u8::ServerControlItem.new(
  can_skip_until: 24.0, part_hold_back: 1.0,
  can_block_reload: true
)
part_inf = M3u8::PartInfItem.new(part_target: 0.5)
playlist = M3u8::Playlist.new(
  version: 9, target: 4, sequence: 100,
  server_control: server_control, part_inf: part_inf,
  live: true
)

item = M3u8::SegmentItem.new(duration: 4.0, segment: 'seg100.mp4')
playlist.items << item

part = M3u8::PartItem.new(
  duration: 0.5, uri: 'seg101.0.mp4', independent: true
)
playlist.items << part

hint = M3u8::PreloadHintItem.new(type: 'PART', uri: 'seg101.1.mp4')
playlist.items << hint

report = M3u8::RenditionReportItem.new(
  uri: '../alt/index.m3u8', last_msn: 101, last_part: 0
)
playlist.items << report
```

### Writing playlists

You can pass an IO object to the write method:

```ruby
require 'tempfile'
file = Tempfile.new('test')
playlist.write(file)
```

You can also access the playlist as a string:

```ruby
playlist.to_s
```

M3u8::Writer is the class that handles generating the playlist output.

Alternatively you can set codecs rather than having it generated automatically:

```ruby
options = { width: 1920, height: 1080, codecs: 'avc1.66.30,mp4a.40.2',
            bandwidth: 540, uri: 'test.url' }
item = M3u8::PlaylistItem.new(options)
```

## Usage (parsing playlists)

```ruby
file = File.open 'spec/fixtures/master.m3u8'
playlist = M3u8::Playlist.read(file)
playlist.master?
# => true
```

Query playlist properties:

```ruby
playlist.master?
# => true (contains variant streams)
playlist.live?
# => false (master playlists are never live)
```

For media playlists, `duration` returns total segment duration:

```ruby
media = M3u8::Playlist.read(
  File.open('spec/fixtures/event_playlist.m3u8')
)
media.live?
# => false
media.duration
# => 17.0 (sum of all segment durations)
```

Access items and their attributes:

```ruby
playlist.items.first
#  => #<M3u8::PlaylistItem ...>

media.segments.first.duration
# => 6.0
media.segments.first.segment
# => "segment0.mp4"
```

Convenience methods filter items by type:

```ruby
playlist.playlists    # => [PlaylistItem, ...]
playlist.segments     # => [SegmentItem, ...]
playlist.media_items  # => [MediaItem, ...]
playlist.keys         # => [KeyItem, ...]
playlist.maps         # => [MapItem, ...]
playlist.date_ranges  # => [DateRangeItem, ...]
playlist.parts        # => [PartItem, ...]
playlist.session_data # => [SessionDataItem, ...]
```

Parse an LL-HLS playlist:

```ruby
file = File.open 'spec/fixtures/ll_hls_playlist.m3u8'
playlist = M3u8::Playlist.read(file)
playlist.server_control.can_block_reload
# => true
playlist.part_inf.part_target
# => 0.5
```

M3u8::Reader is the class that handles parsing if you want more control over the process.

## Codec string generation

Generate the codec string based on audio and video codec options without dealing with a playlist instance:

```ruby
options = { profile: 'baseline', level: 3.0, audio_codec: 'aac-lc' }
codecs = M3u8::Playlist.codecs(options)
# => "avc1.66.30,mp4a.40.2"
```

### Video codecs

| Profile | Description |
|---------|-------------|
| `baseline`, `main`, `high` | H.264/AVC |
| `hevc-main`, `hevc-main-10` | HEVC/H.265 |
| `av1-main`, `av1-high` | AV1 |

### Audio codecs

| Value | Codec |
|-------|-------|
| `aac-lc` | AAC-LC |
| `he-aac` | HE-AAC |
| `mp3` | MP3 |
| `ac-3` | AC-3 (Dolby Digital) |
| `ec-3`, `e-ac-3` | E-AC-3 (Dolby Digital Plus) |
| `flac` | FLAC |
| `opus` | Opus |

## Supported tags

### Master playlist tags
* `EXT-X-STREAM-INF` / `EXT-X-I-FRAME-STREAM-INF` — including `STABLE-VARIANT-ID`, `VIDEO-RANGE`, `ALLOWED-CPC`, `PATHWAY-ID`, `REQ-VIDEO-LAYOUT`, `SUPPLEMENTAL-CODECS`, `SCORE`
* `EXT-X-MEDIA` — including `STABLE-RENDITION-ID`, `BIT-DEPTH`, `SAMPLE-RATE`
* `EXT-X-SESSION-DATA`
* `EXT-X-SESSION-KEY`
* `EXT-X-CONTENT-STEERING`

### Media playlist tags
* `EXT-X-TARGETDURATION`
* `EXT-X-MEDIA-SEQUENCE`
* `EXT-X-DISCONTINUITY-SEQUENCE`
* `EXT-X-PLAYLIST-TYPE`
* `EXT-X-I-FRAMES-ONLY`
* `EXT-X-ALLOW-CACHE`
* `EXT-X-ENDLIST`

### Media segment tags
* `EXTINF`
* `EXT-X-BYTERANGE`
* `EXT-X-DISCONTINUITY`
* `EXT-X-KEY`
* `EXT-X-MAP`
* `EXT-X-PROGRAM-DATE-TIME`
* `EXT-X-DATERANGE`
* `EXT-X-GAP`
* `EXT-X-BITRATE`

### Universal tags
* `EXT-X-INDEPENDENT-SEGMENTS`
* `EXT-X-START`
* `EXT-X-DEFINE`
* `EXT-X-VERSION`

### Low-Latency HLS tags
* `EXT-X-SERVER-CONTROL`
* `EXT-X-PART-INF`
* `EXT-X-PART`
* `EXT-X-SKIP`
* `EXT-X-PRELOAD-HINT`
* `EXT-X-RENDITION-REPORT`

## Contributing

1. Fork it ( https://github.com/sethdeckard/m3u8/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the specs, make sure they pass and that new features are covered. Code coverage should be 100%.
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## License
MIT License - See [LICENSE.txt](https://github.com/sethdeckard/m3u8/blob/master/LICENSE.txt) for details.
