package Noembed::Source::GitHub;

use parent 'Noembed::Source';

my $re = qr{https?://gist\.github\.com/[0-9a-fA-f]+$}i;

sub matches {
  my ($self, $url) = @_;
  return $url =~ $re;
}

sub request_url {
  my ($self, $url) = @_;
  return "$url.pibb";
}

sub filter {
  my ($self, $body) = @_;
  return +{
    html => $body,
  };
}
