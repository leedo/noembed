package Noembed::Provider::Lockerz;

use parent 'Noembed::ImageProvider';

use Web::Scraper;

sub prepare_provider {
  my $self = shift;
  $self->{scraper} = scraper {
    process '#photo', src => '@src';
    process 'figcaption > p', title => 'TEXT';
  };
}

sub image_data {
  my ($self, $body) = @_;
  $self->{scraper}->scrape($body);
}

sub provider_name { 'Lockerz' }
sub patterns { 'http://lockerz\.com/[sd]/\d+' }

1;
