package Noembed::Source::Wikipedia;

use Web::Scraper;

use parent 'Noembed::Source';

sub request_url {
  my ($self, $url) = @_;
  return $url;
}

sub filter {
  my ($self, $body) = @_;
  return $body;
}

sub patterns {
  return (
    qr{http://[^\.]+\.wikipedia\.org/wiki/.*}i
  );
}

1;
