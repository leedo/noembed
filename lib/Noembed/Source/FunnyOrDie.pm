package Noembed::Source::FunnyOrDie;

use parent 'Noembed::oEmbedSource';

sub provider_name { "Funny or Die" }
sub oembed_url { "http://www.funnyordie.com/oembed.json" }
sub patterns { 'http://www.funnyordie.com/videos/[^/]+/.+' }

1;
