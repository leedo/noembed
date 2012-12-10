package Noembed::Source::Spotify;

use Web::Scraper;
use Noembed::Util;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process 'meta[property="og:title"]', title => '@content';
    process 'meta[property="og:audio"]', link => '@content';
    process 'meta[property="music:musician"]', musician => '@content';
  };
  $self->{artist_scraper} = scraper {
    process 'meta[property="og:title"]', name => '@content';
  };
}

sub patterns { 'https?://open\.spotify\.com/(track|album)/([0-9a-zA-Z]{22})' }
sub provider_name { "Spotify" }

sub post_download {
  my ($self, $body, $req, $cb) = @_;
  my $data = $self->{scraper}->scrape($body);
  Noembed::Util::http_get $data->{musician}, sub {
    my ($body, $headers) = @_;
    my $artist = $self->{artist_scraper}->scrape($body); 
    $data->{artist} = $artist->{name};
    $cb->($data);
  };
}

sub serialize {
  my ($self, $data, $req) = @_;

  return +{
    title => $data->{title} . " by " . $data->{artist},
    html  => $self->render($data),
  };
}

1;
