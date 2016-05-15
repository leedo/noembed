package Noembed::Provider::Mixcloud;

use parent 'Noembed::oEmbedProvider';

sub provider_name {"Mixcloud"}
sub patterns {'https?://(?:www\.)?mixcloud\.com/(.+)'}
sub build_url {
  my ($self, $req) = @_;
  my $url = $req->captures->[0];
  return "https://www.mixcloud.com/oembed/?url=https://www.mixcloud.com/$url&format=json";
}

1;
