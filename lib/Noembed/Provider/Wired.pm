package Noembed::Provider::Wired;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "Wired" }
sub patterns { 'http://wired\.com/[^/]+/\d+/\d+/[^/]+/?$' }

1;
