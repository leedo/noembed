package Noembed::Source::Instagram;

use Web::Scraper;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;

  $self->{re} = qr{https?://instagr\.am/p/.+};
  $self->{scraper} = scraper {
    process 'meta[property="og:title"]', title => '@content';
    process 'meta[property="og:image"]', url => '@content';
  };
}

sub matches {
  my ($self, $url) = @_;
  return $url =~ $self->{re};
}

sub provider_name { "Instagram" }

sub filter {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);

  return +{
    title => $data->{title},
    html  => "<img src=\"$data->{url}\">",
  };
}

1;
