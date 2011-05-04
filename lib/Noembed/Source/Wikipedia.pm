package Noembed::Source::Wikipedia;

use Web::Scraper;
use JSON;

use parent 'Noembed::Source';

my $re = qr{http://[^\.]+\.wikipedia\.org/wiki/.*}i;

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process "#firstHeading", title => 'TEXT';
    process "#bodyContent p:first-child", html => 'HTML';
  };
}

sub provider_name { "Wikipedia" }

sub filter {
  my ($self, $body) = @_;

  my $res = $self->{scraper}->scrape($body);
  return $res;
}

sub matches {
  my ($self, $url) = @_;
  return $url =~ $re;
}

1;
