package Noembed::Provider::Muki;

use parent 'Noembed::oEmbedProvider';

sub provider_name { "Muki" }
sub patterns { 'https?://muki\.io/(embed/)?(.+)' }
sub options { qw/autoplay/ }

sub build_url {
  my ($self, $req) = @_;
  return "https://muki.io/oembed/" . $req->captures->[1];
}

1;