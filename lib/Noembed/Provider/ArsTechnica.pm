package Noembed::Provider::ArsTechnica;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "Ars Technica" }
sub patterns { 'http://arstechnica\.com/[^/]+/\d+/\d+/[^/]+/?$' }

1;
