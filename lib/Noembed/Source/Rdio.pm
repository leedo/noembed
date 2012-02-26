package Noembed::Source::Rdio;

use parent 'Noembed::oEmbedSource';

sub provider_name { "Rdio" }

sub patterns {
  'http://www\.rdio\.com/#/artist/[^/]+/album/[^/]+/?',
  'http://www\.rdio\.com/#/artist/[^/]+/album/[^/]+/track/[^/]+/?',
  'http://www\.rdio\.com/#/people/[^/]+/playlists/\d+/[^/]+',
}

sub oembed_url { "http://www.rdio.com/api/oembed/" }

1;
