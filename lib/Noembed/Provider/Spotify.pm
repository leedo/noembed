package Noembed::Provider::Spotify;

use Web::Scraper;
use Noembed::Util;
use parent 'Noembed::Provider';

sub prepare_provider {
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

sub serialize {
  my ($self, $body, $req) = @_;

  my $data = $self->{scraper}->scrape($body);

  my $res = Noembed::Util->http_get($data->{musician});
  my $artist = $self->{artist_scraper}->scrape($res->decoded_content); 
  $data->{artist} = $artist->{name};

  return +{
    title => $data->{title} . " by " . $data->{artist},
    html  => $self->render($data),
  };
}

1;
