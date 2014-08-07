package Noembed::Provider::GIFUK;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"GIFUK"}
sub patterns {'http://gifuk\.com/s/[0-9a-f]{16}'}
sub oembed_url {'http://gifuk.com/oembed'}

1;
