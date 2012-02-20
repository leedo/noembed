package Noembed::Source::SoundCloud;

use parent 'Noembed::oEmbedSource';

sub provider_name {"SoundCloud"}
sub patterns {'http://soundcloud.com/.*/.*'}
sub oembed_url {'http://soundcloud.com/oembed'}

1;
