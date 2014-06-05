package Noembed::Provider::Flickr;

use parent 'Noembed::oEmbedProvider';

sub provider_name { "Flickr" }
sub patterns { 'https?://(?:www\.)?flickr\.com/.*' }
sub shorturls { 'https?://flic\.kr/p/[a-zA-Z0-9]+' }
sub oembed_url { 'http://www.flickr.com/services/oembed/' }

1;
