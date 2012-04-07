package Noembed::Source::CloudApp;

use Web::Scraper;

use parent 'Noembed::ImageSource';

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process '#content img', src => '@src';
    process '#content img', title => '@alt';
  };
}

sub provider_name { 'CloudApp' }
sub patterns { 'http://cl\.ly/[0-9a-zA-Z]+/?$' }

sub image_data {
  my ($self, $body) = @_;
  $self->{scraper}->scrape($body);
}

1;
