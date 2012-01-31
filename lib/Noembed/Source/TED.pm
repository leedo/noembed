package Noembed::Source::TED;

use parent 'Noembed::Source';

use Web::Scraper;

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process 'meta[property="og:video"]', video => '@content';
    process 'meta[property="og:title"]', title => '@content';
    process 'meta[property="og:description"]', description => '@description';
    process 'meta[property="og:image"]', image => '@content';
  };
}

sub provider_name { "TED" }
sub patterns { 'http://www\.ted\.com/talks/[^/]+\.html' }

sub serialize {
  my ($self, $body) = @_;

  my $data = $self->{scraper}->scrape($body);

  return {
    title => $data->{title},
    html  => $self->render($data),
  }
}

1;
