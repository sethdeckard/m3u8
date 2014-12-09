### 0.3.1 (12/09/2014) - Added EXT-X-DISCONTINUITY tag support.

### 0.3.0 (11/26/2014) - DEPRECIATED add_playlist and add_segment on Playlist, manipulate the items array directly instead. Extracted writing of playlists to it's own Writer class (only use directly if you want more control over the process). Added read convience method to Playlist so Reader doesn't have to be used directly unless more control is disired. Simplified validation and other aspects during this refactoring.

### 0.2.1 (11/26/2014) - Moved codec generation / validation to PlaylistItem, allowing for the flexibility to either specify :audio, :level, :profile when creating new instances (codecs value will be automatically generated) or just set the codecs attribute directly.

### 0.2.0 (11/25/2014) - Added ability to parse m3u8 playlists with new Reader class. Introduced two new classes to represent the items that make up a Playlist: PlaylistItem and SegmentItem.

### 0.1.3 (11/23/2014) - Fixed bug in codec string generation.

### 0.1.0 (10/06/2014) - Initial release, provides ability to generate m3u8 playlists (master and segments).