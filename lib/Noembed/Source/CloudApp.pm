package Noembed::Source::CloudApp;

use Web::Scraper;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process '#content', html => 'RAW';
    process 'h2', title => 'TEXT';
  };
}

sub provider_name { 'CloudApp' }
sub patterns { 'http://cl\.ly/[0-9a-zA-Z]+' }

sub serialize {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);

  return +{
    title => $data->{title},
    html => $data->{html},
  };
}

1;
