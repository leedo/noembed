package Noembed::Provider::Audiomack;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"Audiomack"}
sub patterns {'https?://audiomack\.com/(song|album|playlist)/.+'}
sub oembed_url {'https://audiomack.com/oembed'}

1;
