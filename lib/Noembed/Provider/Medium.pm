package Noembed::Provider::Medium;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "Medium" }
sub patterns { 'http://(?:www\.)?medium\.com/\d{4}/\d{1,2}/\d{1,2}/\d+/[^/]+/?$' }

1;
