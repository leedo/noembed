package Noembed::Source::Flickr;

use parent 'Noembed::oEmbedSource';

sub provider_name {"Flickr"}
sub patterns {'http://(?:www\.)?flickr\.com/.*'}
sub oembed_url {'http://www.flickr.com/services/oembed/'}

1;
