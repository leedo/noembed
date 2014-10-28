package Noembed::Provider::GiantBomb;

use JSON;
use URI;
use URI::QueryParam;
use HTML::Entities;
use Web::Scraper;

use parent 'Noembed::Provider';

# bleh, just use youtube's serialize method
# it has fancy things like time jumping
*{__PACKAGE__."::serialize"} = *Noembed::Provider::YouTube::serialize;

sub prepare_provider {
  my $self = shift;
  $self->{scraper} = scraper {
    process "div[data-video]", video => sub {
      my $el = shift;
      from_json decode_entities $el->attr("data-video");
    };
  };
}

sub provider_name { "GiantBomb" }
sub options { qw/maxwidth maxheight autoplay/}
sub patterns { 'https?://www\.giantbomb\.com/videos/[^/]+/\d+-\d+/?' }

sub pre_download {
  my ($self, $req, $cb) = @_;

  $req->http_get($req->url, sub {
    my ($body, $headers) = @_;
    if ($headers->{Status} == 200) {
      my $video = $self->{scraper}->scrape($body);
      my $uri = URI->new("https://www.youtube.com/oembed/");
      $uri->query_param("url", "https://www.youtube.com/watch?v=$video->{video}{youtubeID}");
      $req->content_url($uri);
    }
    $cb->($req);
  });
}

1;
