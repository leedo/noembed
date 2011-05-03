package Noembed::Source::Wikipedia;

use Web::Scraper;
use JSON;

use parent 'Noembed::Source';

sub new {
  my ($class, %args) = @_;

  my $self = {
    pattern => qr{http://[^\.]+\.wikipedia\.org/wiki/.*}i,
    scraper => scraper {
      process "#firstHeading", title => 'TEXT';
      process "#bodyContent p:first-child", summary => 'HTML';
    },
  };

  bless $self, $class;
}

sub request_url {
  my ($self, $url) = @_;

  return $url;
}

sub filter {
  my ($self, $body) = @_;

  my $res = $self->{scraper}->scrape($body);
  return encode_json $res;
}

sub matches {
  my ($self, $url) = @_;
  return $url =~ $self->{pattern};
}

1;
