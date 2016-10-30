package Noembed::Provider::Spreaker;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"Spreaker"}
sub patterns {'https?://(?:www\.)spreaker\.com/.+'}
sub oembed_url {'https://api.spreaker.com/oembed'}

1;
