package Noembed::Provider::Clyp;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"Clyp"}
sub patterns {'http://clyp\.it/.*'}
sub oembed_url {'http://api.clyp.it/oembed/'}

1;
