package Noembed::Provider::BoingBoing;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "Boing Boing" }
sub patterns { 'http://boingboing\.net/\d{4}/\d{2}/\d{2}/[^/]+\.html' }

1;
