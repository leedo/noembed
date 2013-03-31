package Noembed::Provider::Hulu;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"Hulu"}
sub patterns {'http://www\.hulu\.com/watch/.*'}
sub oembed_url {'http://www.hulu.com/api/oembed.json'}

1;
