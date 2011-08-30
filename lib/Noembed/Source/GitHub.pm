package Noembed::Source::GitHub;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{re} = qr{https?://gist\.github\.com/[0-9a-fA-f]+$}i;
}

sub matches {
  my ($self, $url) = @_;
  return $url =~ $self->{re};
}

sub request_url {
  my ($self, $req) = @_;
  return $req->url.".pibb";
}

sub filter {
  my ($self, $body) = @_;

  # strip off leading style tag.
  # it is setting a font-size on body
  $body =~ s/<style.+?<\/style>//;

  return +{
    html => $body,
  };
}

sub provider_name { "GitHub" }

1;
