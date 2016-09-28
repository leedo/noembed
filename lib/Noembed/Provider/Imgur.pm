package Noembed::Provider::Imgur;

use parent 'Noembed::oEmbedProvider';

sub patterns { 'https?://imgur\.com/(?:[^\/]+/)?[0-9a-zA-Z]+$' }
sub provider_name { "Imgur" }
sub oembed_url { "http://api.imgur.com/oembed.json" }

1;
