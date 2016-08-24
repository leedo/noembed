package Noembed::Provider::Twitter;

use parent 'Noembed::oEmbedProvider';

sub patterns { 'https?://(?:www|mobile\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)' }
sub provider_name { "Twitter" }
sub oembed_url { "https://publish.twitter.com/oembed" }

1;
