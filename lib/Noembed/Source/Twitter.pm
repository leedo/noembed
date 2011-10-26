package Noembed::Source::Twitter;

use JSON;
use Text::MicroTemplate qw/encoded_string/;

use parent 'Noembed::Source';

sub patterns { 'https?://(?:www\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)' }
sub provider_name { "Twitter" }

sub request_url {
  my ($self, $req) = @_;
  my $id = $req->captures->[0];
  return "http://api.twitter.com/1/statuses/show/$id.json";
}

sub filter {
  my ($self, $body) = @_;

  my $data = decode_json $body;
  $data->{$_} = encoded_string $data->{$_} for qw/source text/;

  return +{
    title => "Tweet by $data->{user}{name}",
    html  => $self->render($data),
  };
}

1;
