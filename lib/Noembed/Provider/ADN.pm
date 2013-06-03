package Noembed::Provider::ADN;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"ADN"}
sub patterns {'https://(alpha|posts|photos)\.app\.net/.*'}
sub oembed_url {'https://https://alpha-api.app.net/oembed'}

1;
