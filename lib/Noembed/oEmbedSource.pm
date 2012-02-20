package Noembed::oEmbedSource;

use URI;
use URI::QueryParam;
use JSON;
use Carp;
use parent 'Noembed::Source';

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

sub render {
  my $self = shift;
  my $id = Data::GUID->new->as_string;
  $self->{render}->("oEmbed", $id, @_);
}

sub provider_name {
  croak "must override provider_name method";
}

sub oembed_url {
  croak "must override oembed_url method";
}

sub build_url {
  my ($self, $req) = @_;
  my $uri = URI->new($self->oembed_url);
  $uri->query_param("url", $req->url);
  $uri->query_param("format", "json");
  return $uri;
}

1;
