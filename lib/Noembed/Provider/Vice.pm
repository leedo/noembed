package Noembed::Provider::Vice;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "VICE" }
sub patterns { 'https?://(?:www\.)?vice\.com/[^/]+/?' }

1;
