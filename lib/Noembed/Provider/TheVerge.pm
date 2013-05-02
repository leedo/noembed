package Noembed::Provider::TheVerge;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "The Verge" }
sub patterns { 'http://(?:www\.)?theverge\.com/\d{4}/\d{1,2}/\d{1,2}/\d+/[^/]+/?$' }

1;
