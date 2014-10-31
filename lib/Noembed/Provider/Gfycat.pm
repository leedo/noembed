package Noembed::Provider::Gfycat;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "Gfycat" }
sub patterns { 'http://gfycat\.com/([a-zA-Z]+)' }

1;
