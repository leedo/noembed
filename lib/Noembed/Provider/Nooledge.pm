package Noembed::Provider::Nooledge;

use JSON;
use URI;
use URI::QueryParam;

use parent 'Noembed::Provider';

sub patterns {
  'https?://www\.nooledge\.com/\!/Vid/.+',
  'https?://v\.nldg\.me/.+'
}

sub provider_name { "Nooledge" }
sub options { qw/maxwidth maxheight title/ }

sub build_url {
  my ($self, $req) = @_;
  my $uri = URI->new("https://www.nooledge.com/oembed.json");
  $uri->query_param("url", $req->url);
  return $uri;
}

sub serialize {
  my ($self, $body) = @_;
  from_json $body;
}

1;
