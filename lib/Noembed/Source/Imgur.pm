package Noembed::Source::Imgur;

use Web::Scraper;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'title', title => 'TEXT';
    process 'link[rel="image_src"]', src => '@href';
  };
}

sub patterns { 'http://imgur\.com/([0-9a-zA-Z]+)$' }
sub provider_name { "Imgur" }

sub serialize {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);

  if ($data->{title}) {
    $data->{title} =~ s/ - Imgur//;
  }

  return +{
    html => "<img src=\"$data->{src}\">",
    title => $data->{title} || "No title",
  }
}

1;
