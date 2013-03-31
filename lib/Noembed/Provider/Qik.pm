package Noembed::Provider::Qik;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"Qik"}
sub patterns {'http://qik\.com/video/.*'}
sub oembed_url {'http://qik.com/api/oembed.json'}

1;
