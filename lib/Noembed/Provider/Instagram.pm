package Noembed::Provider::Instagram;

use Web::Scraper;

use parent 'Noembed::ImageProvider';

sub prepare_provider {
  my $self = shift;

  $self->{scraper} = scraper {
    process 'meta[property="og:image"]', src => '@content';
    process 'div.caption', title => 'TEXT';
  };
}

sub image_data {
  my ($self, $body) = @_;
  $self->{scraper}->scrape($body);
}

sub patterns { 'https?://(?:www\.)?instagr(?:\.am|am\.com)/p/.+' }
sub provider_name { "Instagram" }

1;
