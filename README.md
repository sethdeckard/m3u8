[![Gem Version](https://badge.fury.io/rb/m3u8.svg)](http://badge.fury.io/rb/m3u8)
[![Build Status](https://travis-ci.org/sethdeckard/m3u8.svg?branch=master)](https://travis-ci.org/sethdeckard/m3u8)
[![Coverage Status](https://coveralls.io/repos/sethdeckard/m3u8/badge.png)](https://coveralls.io/r/sethdeckard/m3u8)
[![Code Climate](https://codeclimate.com/github/sethdeckard/m3u8/badges/gpa.svg)](https://codeclimate.com/github/sethdeckard/m3u8)
[![Dependency Status](https://gemnasium.com/sethdeckard/m3u8.svg)](https://gemnasium.com/sethdeckard/m3u8)
# m3u8

m3u8 provides generation of m3u8 playlists used the [HTTP Live Streaming](https://developer.apple.com/library/ios/documentation/networkinginternet/conceptual/streamingmediaguide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008332-CH1-SW1) (HLS) specification created by Apple. This is useful if you wish to generate m3u8 playlists on the fly in your web application (to integrate authentication, do something custom,  etc) while of course serving up the actual MPEG transport stream files (.ts) from a CDN. You could also use m3u8 to generate playlist files as part of an encoding pipeline.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'm3u8'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install m3u8

## Usage


	require 'm3u8'
	
	#create a master playlist and add child playlists for adaptive bitrate streaming:
	playlist = M3u8::Playlist.new
	options = { :width => 1920, :height => 1080, :profile => 'high', :level => 4.1, :audio => 'aac-lc'}
    playlist.add_playlist '2', 'http://playlist_url_or_path_file', 50000, options
    
    #create a standard playlist and add TS segments:
    playlist = M3u8::Playlist.new
    playlist.add_segment 11.344644, "1080-7mbps00000.ts"
    
    #just get the codec string for custom use
    options = { :profile => 'baseline', :level => 3.0, :audio => 'aac-lc' }
    codecs = M3u8::Playlist.codecs options
    #=> "avc1.66.30,mp4a.40.2"
	
	#specify options for playlist, these are ignored if playlist becomes a master playlist (child playlist added):
	options = { :version => 1, :cache => false, :target => 12, :sequence => 1}
    playlist = M3u8::Playlist.new options
    
    #values for :audio (Codec name)
    #aac-lc, he-aac, mp3
    
    #values for :profile (H.264 Profile)
    #baseline, main, high
    
    #values for :level
    #3.0, 3.1, 4.0, 4.1
    
    #not all Levels and Profiles can be combined, consult H.264 documentation
	
## Features
* Distinction between segment and master playlists are handled automatically (no need to use a different class)
* Automatically generates the audio/video codec string based on names and options you are familar with.
* Provides validation of input when adding playlists or segments.
* Allows all options to be configured on a playlist (caching, version, etc.)
* Can write playlist to StringIO/File or to_s.

## Contributing

1. Fork it ( https://github.com/sethdeckard/m3u8/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
