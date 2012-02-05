package Noembed::Source::YFrog;

use Web::Scraper;

use parent 'Noembed::ImageSource';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process '#main_image', src => '@src';
  };
}

sub image_data {
  my ($self, $body) = @_;
  $self->{scraper}->scrape($body);
}

sub patterns { 'http://yfrog\.com/[0-9a-zA-Z]+' }
sub provider_name { 'YFrog' }

1;
