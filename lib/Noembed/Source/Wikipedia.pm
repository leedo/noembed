package Noembed::Source::Wikipedia;

use Web::Scrapper;

use parent 'Noembed::Source';

sub new {
}

sub request_url {
  my ($self, $url) = @_;
  return $url;
}

sub filter {
  # extract content here
}

sub patterns {
  return (
    qr{http://www\.wikipedia\.org/.*}i
  );
}

1;
