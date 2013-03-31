package Noembed::Provider::Imgur;

use Web::Scraper;

use parent 'Noembed::ImageProvider';

sub prepare_provider {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'link[rel="image_src"]', src => '@href';
  };
}

sub image_data {
  my ($self, $body) = @_;
  $self->{scraper}->scrape($body);
}

sub patterns { 'http://imgur\.com/([0-9a-zA-Z]+)$' }
sub provider_name { "Imgur" }

1;
