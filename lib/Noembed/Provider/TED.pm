package Noembed::Provider::TED;

use parent 'Noembed::oEmbedProvider';

sub provider_name { "TED" }
sub patterns { 'https?://www\.ted\.com/talks/.+' }
sub oembed_url { 'https://www.ted.com/talks/oembed.json' }

1;
