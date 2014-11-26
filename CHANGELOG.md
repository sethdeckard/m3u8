### 0.2.1 (11/26/2014) - Moved codec generation / validation to PlaylistItem, allowing for the flexibility to either specify :audio, :level, :profile when creating new instances (codecs value will be automatically generated) or just set the codecs attribute directly.

### 0.2.0 (11/25/2014) - Added ability to parse m3u8 playlists with new Reader class. Introduced two new classes to represent the items that make up a Playlist: PlaylistItem and SegmentItem.

### 0.1.3 (11/23/2014) - Fixed bug in codec string generation.

### 0.1.0 (10/06/2014) - Initial release, provides ability to generate m3u8 playlists (master and segments).