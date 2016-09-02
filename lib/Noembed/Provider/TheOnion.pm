package Noembed::Provider::TheOnion;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "The Onion" }
sub patterns { 'http://www\.theonion\.com/articles?/[^/]+/?' }

1;
