package Noembed::Provider::Gumlet;

use JSON;
use URI;
use URI::QueryParam;

use parent 'Noembed::Provider';

sub patterns {
  'https?://gumlet\.tv/watch/.+',
  'https?://play\.gumlet\.io/embed/.+'
}
sub provider_name { "Gumlet" }

sub options {
  qw/maxwidth maxheight autoplay loop playsinline
     player_color thumbnail background start_high_res
     disable_player_controls audio_track_language caption_language/
}

sub build_url {
  my ($self, $req) = @_;
  my $uri = URI->new("https://api.gumlet.com/v1/oembed");
  $uri->query_param("url", $req->url);
  return $uri;
}

sub serialize {
  my ($self, $body) = @_;
  from_json $body;
}

1;
