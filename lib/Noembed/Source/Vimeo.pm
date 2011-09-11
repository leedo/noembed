package Noembed::Source::Vimeo;

use JSON;
use URI;
use URI::QueryParam;

use parent 'Noembed::Source';

sub patterns { 'http://(?:www\.)?vimeo\.com/.+' }
sub provider_name { "Vimeo" }

sub request_url {
  my ($self, $req) = @_;
  my $uri = URI->new("http://www.vimeo.com/api/oembed.json");

  $uri->query_param("url", $req->url);
  if ($req->maxwidth) {
    $uri->query_param("maxwidth", $req->maxwidth);
  }

  if ($req->maxheight) {
    $uri->query_param("maxheight", $req->maxheight);
  }

  return $uri->as_string;
}

sub filter {
  my ($self, $body) = @_;
  decode_json $body;
}

1;
