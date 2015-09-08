package Noembed::Provider::GlobalGiving;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"GlobalGiving"}
sub patterns {'https?://www\.globalgiving\.org/((micro)?projects|funds)/.*'}
sub oembed_url {'http://www.globalgiving.org/dy/v2/oembed/'}

1;
