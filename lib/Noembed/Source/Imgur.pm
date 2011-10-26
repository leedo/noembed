package Noembed::Source::Imgur;

use JSON;

use parent 'Noembed::Source';

sub patterns { 'http://imgur\.com/([0-9a-zA-Z]+)$' }
sub provider_name { "Imgur" }

sub request_url {
  my ($self, $req) = @_;
  my ($hash) = $req->captures;
  "http://api.imgur.com/2/image/$hash.json";
}

sub filter {
  my ($self, $body) = @_;
  my $data = decode_json($body);

  return +{
    html => "<img src=\"$data->{image}{links}{original}\">",
    title => $data->{image}{image}{title} || "No title",
  }
}

1;
