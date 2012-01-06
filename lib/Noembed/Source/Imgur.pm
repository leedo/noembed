package Noembed::Source::Imgur;

use Web::Scraper;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'link[rel="image_src"]', src => '@href';
  };
}

sub patterns { 'http://imgur\.com/([0-9a-zA-Z]+)$' }
sub provider_name { "Imgur" }

sub serialize {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);

  die "No image found" unless $data->{src};

  return +{
    html => $self->render($data),
  }
}

1;
