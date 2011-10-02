package Noembed::Source::Imgur;

use Web::Scraper;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process 'h2', title => 'TEXT';
    process 'link[rel="image_src"]', url => '@href';
  };
}

sub patterns { 'http://imgur\.com/[\w\d]+' }
sub provider_name { "Imgur" }

sub filter {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);

  return +{
    title => $data->{title},
    html  => "<img src=\"$data->{url}\">",
  }
}

1;
