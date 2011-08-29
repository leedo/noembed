package Noembed::Source::Twitter;

use JSON;
use Text::MicroTemplate qw/encoded_string/;

use parent 'Noembed::Source';

sub matches {
  my ($self, $url) = @_;
  return $url =~ $self->{re};
}

sub prepare_source {
  my $self = shift;
  $self->{re} = qr{https?://(?:www\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)};
}

sub request_url {
  my ($self, $req) = @_;
  if ($req->url =~ $self->{re}) {
    my $id = $1;
    return "http://api.twitter.com/1/statuses/show/$id.json";
  }
}

sub provider_name { "Twitter" }

sub filter {
  my ($self, $body) = @_;

  my $data = decode_json $body;
  $data->{$_} = encoded_string $data->{$_} for qw/source text/;

  +{
    title => "Tweet by $data->{user}{name}",
    html  => $self->render($data),
  };
}

1;
