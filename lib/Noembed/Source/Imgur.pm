package Noembed::Source::Imgur;

use Web::Scraper;

use parent 'Noembed::ImageSource';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'link[rel="image_src"]', src => '@href';
  };
}

sub patterns { 'http://imgur\.com/([0-9a-zA-Z]+)$' }
sub provider_name { "Imgur" }

1;
