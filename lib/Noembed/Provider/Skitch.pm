package Noembed::Provider::Skitch;

use Web::Scraper;

use parent "Noembed::ImageProvider";

sub prepare_provider {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'link[rel="image_src"]', src => '@href';
    process 'meta[name="title"]', title => '@content';
  };
}

sub image_data {
  my ($self, $body) = @_;
  $self->{scraper}->scrape($body);
}

sub provider_name {"Skitch"}
sub patterns {"https?://(?:www\.)?skitch\.com/([^/]+)/[^/]+/.+"}
sub shorturls { "http://skit\.ch/[^/]+" }

1;
