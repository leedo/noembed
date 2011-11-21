package Noembed::Source::Skitch;

use Web::Scraper;

use parent "Noembed::Source";

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'link[rel="image_src"]', src => '@href';
    process 'meta[name="title"]', title => '@content';
  };
}

sub provider_name {"Skitch"}
sub patterns {"https?://(?:www\.)?skitch\.com/([^/]+)/[^/]+/.+"}

sub serialize {
  my ($self, $body, $req) = @_;
  my $data = $self->{scraper}->scrape($body);

  my $user = $req->captures->[0];
  return +{
    title => "$data->{title} by $user",
    html  => $self->render($data),
  };

}

1;
