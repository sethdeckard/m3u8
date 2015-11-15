[![Gem Version](https://badge.fury.io/rb/m3u8.svg)](http://badge.fury.io/rb/m3u8)
[![Build Status](https://travis-ci.org/sethdeckard/m3u8.svg?branch=master)](https://travis-ci.org/sethdeckard/m3u8)
[![Coverage Status](https://coveralls.io/repos/sethdeckard/m3u8/badge.png)](https://coveralls.io/r/sethdeckard/m3u8)
[![Code Climate](https://codeclimate.com/github/sethdeckard/m3u8/badges/gpa.svg)](https://codeclimate.com/github/sethdeckard/m3u8)
[![Dependency Status](https://gemnasium.com/sethdeckard/m3u8.svg)](https://gemnasium.com/sethdeckard/m3u8)
[![security](https://hakiri.io/github/sethdeckard/m3u8/master.svg)](https://hakiri.io/github/sethdeckard/m3u8/master)
# m3u8

m3u8 provides generation and parsing of m3u8 playlists used the [HTTP Live Streaming](https://developer.apple.com/library/ios/documentation/networkinginternet/conceptual/streamingmediaguide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008332-CH1-SW1) (HLS) specification created by Apple. This is useful if you wish to generate m3u8 playlists on the fly in your web application (to integrate authentication, do something custom,  etc) while of course serving up the actual MPEG transport stream files (.ts) from a CDN. You could also use m3u8 to generate playlist files as part of an encoding pipeline. You can also parse existing playlists, add content to them and generate a new output.

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
item = M3u8::PlaylistItem.new options
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
  
Create a standard playlist and add MPEG-TS segments via SegmentItem. You can also specify options for this type of playlist, however these options are ignored if playlist becomes a master playlist (anything but segments added):
```ruby
options = { version: 1, cache: false, target: 12, sequence: 1 }
playlist = M3u8::Playlist.new options

item = M3u8::SegmentItem.new duration: 11, segment: 'test.ts'
playlist.items << item
```
    
You can pass an IO object to the write method:
```ruby
require 'tempfile'
f = Tempfile.new 'test'
playlist.write f
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
item = M3u8::PlaylistItem.new options
```
Just get the codec string for custom use:
```ruby
options = { profile: 'baseline', level: 3.0, audio_codec: 'aac-lc' }
codecs = M3u8::Playlist.codecs options
# => "avc1.66.30,mp4a.40.2"
```        
Values for audio_codec (codec name): aac-lc, he-aac, mp3
    
Possible values for profile (H.264 Profile): baseline, main, high.
    
Possible values for level (H.264 Level): 3.0, 3.1, 4.0, 4.1. 

Not all Levels and Profiles can be combined, consult H.264 documentation

## Parsing Usage

```ruby
file = File.open 'spec/fixtures/master.m3u8'
playlist = M3u8::Playlist.read file
playlist.master?
# => true
```
Acess items in playlist:
```ruby
playlist.items.first
#  => #<M3u8::PlaylistItem:0x007fa569bc7698 @program_id="1", @resolution="1920x1080", 
#  @codecs="avc1.640028,mp4a.40.2", @bandwidth="5042000", 
#  @playlist="hls/1080-7mbps/1080-7mbps.m3u8">
```
Create a new playlist item with options:
```ruby
options = { width: 1920, height: 1080, profile: 'high', level: 4.1,
            audio_codec: 'aac-lc', bandwidth: 540, uri: 'test.url' }
item = M3u8::PlaylistItem.new options
#add it to the top of the playlist
playlist.items.insert 0, item
```
M3u8::Reader is the class handles parsing if you want more control over the process.
    
## Features
* Distinction between segment and master playlists is handled automatically (no need to use a different class).
* Automatically generates the audio/video codec string based on names and options you are familar with.
* Provides validation of input when adding playlists or segments.
* Allows all options to be configured on a playlist (caching, version, etc.)
* Supports I-Frames (Intra frames) and Byte Ranges in Segments.
* Supports subtitles, closed captions, alternate audio and video, and comments.
# Supports Session Data in master playlists.
* Supports keys for encrypted media segments (EXT-X-KEY).
* Supports EXT-X-DISCONTINUITY in media segments.
* Can write playlist to an IO object (StringIO/File, etc) or access string via to_s.
* Can read playlists into a model (Playlist and Items) from an IO object.
* Any tag or attribute supported by the object model is supported both parsing and generation of m3u8 playlists.

## Missing (but planned) Features 
* Validation of all attributes and their values to match the rules defined in the spec.
* Still missing support for a few tags and attributes.

## Contributing

1. Fork it ( https://github.com/sethdeckard/m3u8/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the specs, make sure they pass and that new features are covered
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
