package Noembed::Source::oEmbed;

use URI;
use URI::QueryParam;
use JSON;
use parent 'Noembed::Source';

our $DEFAULT = [
  {pattern => 'http://(?:www\.)?flickr.com/.*',     service => 'http://www.flickr.com/services/oembed/'},
  {pattern => 'http://.*\.viddler.com/.*',    service => 'http://lab.viddler.com/services/oembed/'},
  {pattern => 'http://qik.com/video/.*',      service => 'http://qik.com/api/oembed.json'},
  {pattern => 'http://www.hulu.com/watch/.*', service => 'http://www.hulu.com/api/oembed.json'},
  {pattern => 'http://www.slideshare.net/.*/.*', service => 'http://www.slideshare.net/api/oembed/2'},
  {pattern => 'http://soundcloud.com/.*/.*', service => 'http://soundcloud.com/oembed'},
];

sub prepare_source {
  my $self = shift;
  $self->{sites} = $DEFAULT;
  $_->{re} = qr{$_->{pattern}} for @{$self->{sites}};
}

sub options { qw/maxwidth maxheight/ };

sub serialize {
  my ($self, $body, $req) = @_;
  my $data = from_json $body;

  if (!$data->{html}) {
    $data->{html} = $self->render($data, $req->url);
  }

  delete $data->{url};
  return $data;
}

sub patterns {
  my $self = shift;
  return map {$_->{pattern}} @{$self->{sites}};
}
sub provider_name { "oEmbed" }

sub build_url {
  my ($self, $req) = @_;
  for my $site (@{$self->{sites}}) {
    if ($req->url =~ $site->{re}) {
      my $uri = URI->new($site->{service});

      $uri->query_param("url", $req->url);
      $uri->query_param("format", "json");

      return $uri;
    }
  }
}

1;
