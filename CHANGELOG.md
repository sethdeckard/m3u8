0.7.1 (2/23/2017) - Added support for the EXT-X-DATERANGE tag. Minor refactoring of existing classes.

***

0.7.0 (2/3/2017) - Added support for EXT-X-INDEPENDENT-SEGMENTS and EXT-X-START tags. Minor version bumped due to changes of default values for new playlists.

***

0.6.9 (4/24/2016) - Merged pull request #17 from [ghn](https://github.com/ghn). Removes return when parsing next line in playlist.

***

0.6.8 (4/12/2016) - Merged pull request #16 from [ghn](https://github.com/ghn). Fixes issue #12 to support parsing `#EXT-X-PROGRAM-DATE-TIME` correctly in media segments.

***

0.6.7 (4/8/2016) - Merged pull request #15 from [jviney](https://github.com/jviney). Fix: Always render the duration as a decimal integer.

***

0.6.6 (3/30/2016) - Merged pull request #14 from [raphi](https://github.com/raphi). Adds support for non-standard name attribute on `#EXT-X-STREAM-INF` tags.

***

0.6.5 (3/18/2016) - Merged pull requests #11 from [jviney](https://github.com/jviney). Adds codec string for main profile level 4.1.

***

0.6.4 (2/21/2016) - Merged pull requests #8, #9, and #10 from [jviney](https://github.com/jviney). Adds `FRAME-RATE` attribute to `PlayListItem`, fixes `NONE` option for `CLOSED-CAPTIONS` attribute.

***

0.6.3 (2/17/2016) - Merged pull request #7 from [jviney](https://github.com/jviney), fixing bug with require order.

***

0.6.2 (2/16/2016) - Added support for `EXT-X-SESSION-KEY` tags. Merged pulled request #6 from [jviney](https://github.com/jviney), fixing bug with codec string value.

***

0.6.1 (8/15/2015) - Added support for `EXT-X-PROGRAM-DATE-TIME` tags.

***

0.6.0 (6/20/2015) - Added support for `EXT-X-MAP` tags, introduced `ByteRange` class to handled shared byterange parsing/serialization functionality. **Breaking changes**: SegmentItem now exposes a single byterange instance accessor rather than byterange_length and byterange_start, made all parse methods static for consistency (ex: MediaItem.parse).

***

0.5.3 (2/24/2015) - [stan3](https://github.com/stan3) fixed issue recently introduced in Reader where `EXT-X-STREAM-INF` missing resolution would break parsing.

***

0.5.2 (2/18/2015) - Fix issue where `PlaylistItem` method `average_bandwidth` would default to 0 instead of nil when not present in m3u8 being parsed.

***

0.5.1 (2/16/2015) - [takashisite](https://github.com/takashisite) added support for [EXT-X-DISCONTINUITY](https://tools.ietf.org/html/draft-pantos-http-live-streaming-14#section-4.3.2.3). Added support for [EXT-X-KEY](https://tools.ietf.org/html/draft-pantos-http-live-streaming-14#section-4.3.2.4) (keys for encrypted segments).

***

0.5.0 (2/10/2015) - **BREAKING**: renamed PlaylistItem.playlist to PlaylistItem.uri, MediaItem.group to MediaItem.group_id, and PlaylistItem.bitrate to PlaylistItem.bandwidth so attributes more closely match the spec. Added support for EXT-X-I-FRAME-STREAM-INF, EXT-X-I-FRAMES-ONLY, EXT-X-BYTERANGE, and EXT-X-SESSION-DATA.

***

0.4.0 (1/20/2015) - **BREAKING**: Playlist.audio is now Playlist.audio_codec, audio now represents the newly supported AUDIO attribute, please update your code accordingly. Added support for all `EXT-X-MEDIA` attributes as well as the following `EXT-X-STREAM-INF` attributes: `AVERAGE-BANDWIDTH`, `AUDIO`, `VIDEO`, `SUBTILES`, and `CLOSED-CAPTIONS`. This means the library now supports alternate audio / camera angles as well as subtitles and closed captions. The `EXT-X-PLAYLIST-TYPE` attribute is now supported as Playlist.type. [elsurudo](https://github.com/elsurudo) added support for comments/titles in SegmentItems. A bug was also fixed in Reader that prevented reuse of the instance.
***

0.3.2 (1/16/2015) - PROGRAM-ID was removed in protocol version 6, if not provided it will now be omitted with a fix implemented by [elsurudo](https://github.com/elsurudo).

***

0.3.1 (1/15/2015) - [DaKaZ](https://github.com/DaKaZ) added duration method to `Playlist` to get the total length of segments contained within it.

***

0.3.0 (11/26/2014) - **DEPRECIATED** `add_playlist` and `add_segment` on `Playlist`, manipulate the items array directly instead. Extracted writing of playlists to it's own Writer class (only use directly if you want more control over the process). Added read convience method to Playlist so Reader doesn't have to be used directly unless more control is desired. Simplified validation and other aspects during this refactoring.

***

0.2.1 (11/26/2014) - Moved codec generation / validation to `PlaylistItem`, allowing for the flexibility to either specify `:audio`, `:level`, `:profile` when creating new instances (codecs value will be automatically generated) or just set the codecs attribute directly.

***

0.2.0 (11/25/2014) - Added ability to parse m3u8 playlists with new `Reader` class. Introduced two new classes to represent the items that make up a Playlist: `PlaylistItem` and `SegmentItem`.

***

0.1.3 (11/23/2014) - Fixed bug in codec string generation.

***

0.1.0 (10/06/2014) - Initial release, provides ability to generate m3u8 playlists (master and segments).
