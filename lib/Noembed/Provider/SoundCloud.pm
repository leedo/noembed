package Noembed::Provider::SoundCloud;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"SoundCloud"}
sub patterns {'https?://soundcloud.com/.*/.*'}
sub oembed_url {'http://soundcloud.com/oembed'}

1;
