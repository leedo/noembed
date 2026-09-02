package Noembed::Provider::Twitter;

use parent 'Noembed::oEmbedProvider';

# Matches both twitter.com and x.com post URLs (including mobile and hash-bang variants)
sub patterns { 'https?://(?:www|mobile\.)?(?:twitter|x)\.com/(?:#!/)?([^/]+)/status(?:es)?/(\d+)' }

sub build_url {
  my ($self, $req) = @_;
  my $captures = $req->captures;
  # Normalize to twitter.com — publish.x.com/oembed does not reliably resolve x.com-domain URLs
  $req->url(sprintf "https://twitter.com/%s/status/%s", @$captures);
  $self->SUPER::build_url($req);
}

sub provider_name { "X (formerly Twitter)" }
sub oembed_url { "https://publish.x.com/oembed" }

1;
