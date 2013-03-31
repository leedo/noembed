package Noembed::Provider::Picplz;

use parent 'Noembed::ImageProvider';

use Web::Scraper;

sub prepare_provider {
  my $self = shift;

  $self->{scraper} = scraper {
    process '#mainImage', src => '@src';
    process 'div.caption h1', title => 'TEXT';
  };
}

sub image_data {
  my ($self, $body) = @_;
  $self->{scraper}->scrape($body);
}

sub provider_name { "Picplz" }
sub patterns { 'http://picplz\.com/user/[^/]+/pic/[^/]+' }

1;
