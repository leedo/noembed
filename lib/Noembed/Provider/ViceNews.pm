package Noembed::Provider::ViceNews;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "VICE News" }
sub patterns { 'https?://news.vice\.com/[^/]+/?' }

1;
