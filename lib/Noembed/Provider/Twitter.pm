package Noembed::Provider::Twitter;

use parent 'Noembed::oEmbedProvider';

sub patterns { 'https?://(?:www|mobile\.)?twitter\.com/(?:#!/)?([^/]+)/status(?:es)?/(\d+)' }

sub build_url {
  my ($self, $req) = @_;
  my $captures = $req->captures;
  $req->url(sprintf "https://twitter.com/%s/status/%s", @$captures);
  $self->SUPER::build_url($req);
}

sub provider_name { "Twitter" }
sub oembed_url { "https://publish.twitter.com/oembed" }

1;
