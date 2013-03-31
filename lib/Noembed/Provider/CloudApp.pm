package Noembed::Provider::CloudApp;

use Web::Scraper;

use parent 'Noembed::ImageProvider';

sub prepare_provider {
  my $self = shift;

  $self->{scraper} = scraper {
    process '#content img', src => '@src';
    process '#content img', title => '@alt';
  };
}

sub provider_name { 'CloudApp' }
sub patterns { 'http://cl\.ly/(?:image/)?[0-9a-zA-Z]+/?$' }

sub image_data {
  my ($self, $body) = @_;
  $data = $self->{scraper}->scrape($body);
  die "no image found" unless $data->{src};
  return $data;
}

1;
