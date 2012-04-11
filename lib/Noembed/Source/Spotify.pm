package Noembed::Source::Spotify;

use Web::Scraper;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process 'meta[property="og:title"]', title => '@content';
    process 'meta[property="og:audio"]', link => '@content';
    process '#artist .meta-info', artist => 'RAW';
  };
}

sub patterns { 'https?://open\.spotify\.com/(track|album)/([0-9a-zA-Z]{22})' }
sub provider_name { "Spotify" }

sub serialize {
  my ($self, $body, $req) = @_;

  my $data = $self->{scraper}->scrape($body);
  $data->{artist} = clean_html($data->{artist});
  $data->{type} = $req->captures->[0];

  return +{
    title => $data->{title} . " by " . $data->{artist},
    html  => $self->render($data),
  };
}

1;
