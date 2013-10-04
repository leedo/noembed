package Noembed::Provider::DuffelBlog;

use parent 'Noembed::TwitterCardProvider';

sub provider_name { "The Duffel Blog" }
sub patterns { 'http://www\.duffelblog\.com/\d{4}/\d{1,2}/[^/]+/?$' }

1;
