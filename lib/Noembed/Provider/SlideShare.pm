package Noembed::Provider::SlideShare;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"SlideShare"}
sub patterns {'http://www\.slideshare\.net/.*/.*'}
sub oembed_url {'http://www.slideshare.net/api/oembed/2'}

1;
