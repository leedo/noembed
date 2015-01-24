package Noembed::Provider::Wired;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "Wired" }
sub patterns { 'https?://(?:www\.)?wired\.com/([^/]+/)?\d+/\d+/[^/]+/?$' }

1;
