package Noembed::Provider::Flickr;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"Flickr"}
sub patterns {'http://(?:www\.)?flickr\.com/.*'}
sub oembed_url {'http://www.flickr.com/services/oembed/'}

1;
