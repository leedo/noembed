package Noembed::Provider::TickCounter;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"TickCounter"}
sub patterns {'https?://www\.tickcounter\.com/(countdown|countup|ticker|worldclock)/.+'}
sub oembed_url {'https://www.tickcounter.com/oembed'}

1;
