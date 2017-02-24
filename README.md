[![Gem Version](https://badge.fury.io/rb/m3u8.svg)](http://badge.fury.io/rb/m3u8)
[![Build Status](https://travis-ci.org/sethdeckard/m3u8.svg?branch=master)](https://travis-ci.org/sethdeckard/m3u8)
[![Coverage Status](https://coveralls.io/repos/github/sethdeckard/m3u8/badge.svg?branch=master)](https://coveralls.io/github/sethdeckard/m3u8?branch=master)
[![Code Climate](https://codeclimate.com/github/sethdeckard/m3u8/badges/gpa.svg)](https://codeclimate.com/github/sethdeckard/m3u8)
[![Dependency Status](https://gemnasium.com/sethdeckard/m3u8.svg)](https://gemnasium.com/sethdeckard/m3u8)
[![security](https://hakiri.io/github/sethdeckard/m3u8/master.svg)](https://hakiri.io/github/sethdeckard/m3u8/master)
# m3u8

m3u8 provides easy generation and parsing of m3u8 playlists defined in the [HTTP Live Streaming (HLS)](https://tools.ietf.org/html/draft-pantos-http-live-streaming-20) Internet Draft published by Apple.

* The library completely implements version 20 of the HLS Internet Draft.
* Provides parsing of an m3u8 playlist into an object model from any File, StringIO, or string.
* Provides ability to write playlist to a File or StringIO or expose as string via to_s.
* Distinction between a master and media playlist is handled automatically (single Playlist class).
* Optionally, the library can automatically generate the audio/video codecs string used in the CODEC attribute based on specified H.264, AAC, or MP3 options (such as Profile/Level).

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
  
Create a standard playlist and add MPEG-TS segments via SegmentItem. You can also specify options for this type of playlist, however these options are ignored if playlist becomes a master playlist (anything but segments added):

```ruby
options = { version: 1, cache: false, target: 12, sequence: 1 }
playlist = M3u8::Playlist.new(options)

item = M3u8::SegmentItem.new(duration: 11, segment: 'test.ts')
playlist.items << item
```
    
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

Access items in playlist:

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
item = M3u8::PlaylistItem.new(options)
#add it to the top of the playlist
playlist.items.unshift(item)
```

M3u8::Reader is the class handles parsing if you want more control over the process.

## Usage (misc)
Generate the codec string based on audio and video codec options without dealing a playlist instance:

```ruby
options = { profile: 'baseline', level: 3.0, audio_codec: 'aac-lc' }
codecs = M3u8::Playlist.codecs(options)
# => "avc1.66.30,mp4a.40.2"
```  
      
* Values for audio_codec (codec name): aac-lc, he-aac, mp3   
* Values for profile (H.264 Profile): baseline, main, high.
* Values for level (H.264 Level): 3.0, 3.1, 4.0, 4.1. 

Not all Levels and Profiles can be combined and validation is not currently implemented, consult H.264 documentation for further details.


## Roadmap 
* Implement validation of all tags, attributes, and values per HLS I-D.
* Perhaps support for different versions of HLS I-D, defaulting to latest.

## Contributing

1. Fork it ( https://github.com/sethdeckard/m3u8/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the specs, make sure they pass and that new features are covered. Code coverage should be 100%.
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request


## License
MIT License - See [LICENSE.txt](https://github.com/sethdeckard/m3u8/blob/master/LICENSE.txt) for details.
