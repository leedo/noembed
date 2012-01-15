package Noembed::Source::Vimeo;

use JSON;
use URI;
use URI::QueryParam;

use parent 'Noembed::Source';

sub patterns { 'http://(?:www\.)?vimeo\.com/.+' }
sub provider_name { "Vimeo" }

sub options {
  qw/width maxwidth height maxheight byline title
     portrait color autoplay loop xhtml api wmode
     iframe/
}

sub build_url {
  my ($self, $req) = @_;
  my $uri = URI->new("http://www.vimeo.com/api/oembed.json");
  $uri->query_param("url", $req->url);
  return $uri;
}

sub serialize {
  my ($self, $body) = @_;
  from_json $body;
}

1;
