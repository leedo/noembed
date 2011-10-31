package Noembed::Source::YFrog;

use Web::Scraper;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process '#main_image', img => '@src';
    process '#embed-box input', url => '@value';
  };
}

sub patterns { 'http://yfrog\.com/[0-9a-zA-Z]+' }
sub provider_name { 'YFrog' }

sub serialize {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);

  return +{
    html => $self->render($data),
  };
}

1;
