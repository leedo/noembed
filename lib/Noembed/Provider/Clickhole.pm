package Noembed::Provider::Clickhole;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "Clickhole" }
sub patterns { 'http://www\.clickhole\.com/[^/]+/[^/]?' }

1;
