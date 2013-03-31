package Noembed::Provider::Dropbox;

use parent 'Noembed::ImageProvider';

sub patterns { 'https?://www\.(dropbox\.com/s/.+\.(?:jpg|png|gif))' }
sub provider_name { "Dropbox" }
sub shorturls { 'https?://db\.tt/[a-zA-Z0-9]+' }

sub build_url {
  my ($self, $req) = @_;
  return "https://dl.".$req->captures->[0];
}

sub image_data {
  my ($self, $body, $req) = @_;
  return { src => "https://dl.".$req->captures->[0] };
}

1;
