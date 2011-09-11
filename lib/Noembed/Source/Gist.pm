package Noembed::Source::Gist;

use parent 'Noembed::Source';

sub provider_name { "Gist" }
sub pattern { 'https?://gist\.github\.com/[0-9a-fA-f]+' }

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

1;
