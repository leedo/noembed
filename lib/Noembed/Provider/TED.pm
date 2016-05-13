package Noembed::Provider::TED;

use parent 'Noembed::Provider';

use Web::Scraper;

sub prepare_provider {
  my $self = shift;

  $self->{scraper} = scraper {
    process 'meta[property="og:title"]', title => '@content';
    process 'meta[property="og:description"]', description => '@description';
    process 'meta[property="og:image"]', image => '@content';
  };
}

sub provider_name { "TED" }
sub patterns { 'http://www\.ted\.com/talks/.+\.html' }

sub serialize {
  my ($self, $body, $req) = @_;

  my $data = $self->{scraper}->scrape($body);
  $data->{url} = $req->url;
  $data->{url} =~ s/www\.ted\.com/embed\.ted\.com/;

  return {
    title => $data->{title},
    html  => $self->render($data),
  }
}

1;
