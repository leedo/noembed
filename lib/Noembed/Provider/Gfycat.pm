package Noembed::Provider::Gfycat;

use parent 'Noembed::oEmbedProvider';

sub provider_name { "Gfycat" }
sub patterns { 'http://gfycat\.com/([a-zA-Z]+)' }
sub oembed_url { 'https://api.gfycat.com/v1/oembed' }

1;
