package Noembed::Provider::TrailerAddict;

use parent 'Noembed::Provider';

use Web::Scraper;

sub prepare_provider {
  my $self = shift;

  $self->{scraper} = scraper {
    process 'meta[property="og:title"]', title => '@content';
    process 'meta[property="og:video"]', movie => '@content';
    process 'meta[property="og:video:width"]', width => '@content';
    process 'meta[property="og:video:height"]', height => '@content';
  };
}

sub provider_name { "TrailerAddict" }
sub patterns { "http://www\.traileraddict\.com/trailer/[^/]+/trailer" }

sub serialize {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);

  return {
    title => $data->{title},
    html  => $self->render($data),
  };
}

1;
