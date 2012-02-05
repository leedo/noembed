package Noembed::Source::Skitch;

use Web::Scraper;

use parent "Noembed::ImageSource";

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'link[rel="image_src"]', src => '@href';
    process 'meta[name="title"]', title => '@content';
  };
}

sub provider_name {"Skitch"}
sub patterns {"https?://(?:www\.)?skitch\.com/([^/]+)/[^/]+/.+"}

1;
