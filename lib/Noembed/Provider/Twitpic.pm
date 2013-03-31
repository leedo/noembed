package Noembed::Provider::Twitpic;

use parent 'Noembed::ImageProvider';
use JSON;

sub patterns { 'http://(?:www\.)?twitpic\.com/([^/]+)' }
sub provider_name { "Twitpic" }

sub build_url {
  my ($self, $req) = @_;
  "http://api.twitpic.com/2/media/show.json?id=".$req->captures->[0];
}

sub image_data {
  my ($self, $body, $req) = @_;
  my $data = decode_json $body;

  return {
    src => "https://twitpic.com/show/large/".$req->captures->[0],
    title => $data->{message},
  }
}

1;
