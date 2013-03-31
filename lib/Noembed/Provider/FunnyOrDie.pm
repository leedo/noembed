package Noembed::Provider::FunnyOrDie;

use parent 'Noembed::oEmbedProvider';

sub provider_name { "Funny or Die" }
sub oembed_url { "http://www.funnyordie.com/oembed.json" }
sub patterns { 'http://www.funnyordie.com/videos/[^/]+/.+' }

1;
