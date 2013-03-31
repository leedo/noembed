package Noembed::Provider::Viddler;

use parent 'Noembed::oEmbedProvider';

sub provider_name { "Viddler" }
sub patterns {'http://.*\.viddler\.com/.*'}
sub oembed_url {'http://lab.viddler.com/services/oembed/'}

1;
