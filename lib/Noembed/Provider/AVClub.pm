package Noembed::Provider::AVClub;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "The AV Club" }
sub patterns { 'https?://(?:www\.)?avclub\.com/article/[^/]+/?$' }

1;
