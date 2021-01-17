package Noembed::Provider::iHeartRadio;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"iHeartRadio"}
sub patterns {'https?://(?:www\.)iheart\.com/.+'}
sub oembed_url {'https://www.iheart.com/oembed'}

1;
