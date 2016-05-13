package Noembed::Provider::Monoprice;

use Web::Scraper;

use parent 'Noembed::Provider';

sub prepare_provider {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'meta[property="og:title"]', title => '@content';
    process 'meta[property="og:image"]', image => '@content';
    process 'meta[property="og:url"]',   url => '@content';
    process 'table[width="260"][bgcolor="#e4e4e4"]', pricing => sub {shift->as_HTML};
  }
}

sub patterns { 'http://www\.monoprice\.com/products/product\.asp\?.*p_id=\d+' }
sub provider_name { "Monoprice" }

sub serialize {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);

  for (qw(title image url pricing)) {
    die "missing $_" unless defined $data->{$_};
  }

  $data->{pricing} = Noembed::Util->html($data->{pricing});

  return +{
    html => $self->render($data),
    title => $data->{title},
  };
}

1;
