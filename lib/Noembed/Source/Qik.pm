package Noembed::Source::Qik;

use parent 'Noembed::oEmbedSource';

sub provider_name {"Qik"}
sub patterns {'http://qik\.com/video/.*'}
sub oembed_url {'http://qik.com/api/oembed.json'}

1;
