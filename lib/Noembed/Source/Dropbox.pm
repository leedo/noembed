package Noembed::Source::Dropbox;

use parent 'Noembed::ImageSource';

sub patterns { 'https?://www\.(dropbox\.com/s/.+\.(?:jpg|png|gif))' }
sub provider_name { "Dropbox" }

sub build_url {
  my ($self, $req) = @_;
  return "https://dl.".$req->captures->[0];
}

sub image_data {
  my ($self, $body, $req) = @_;
  return { src => "https://dl.".$req->captures->[0] };
}

1;
