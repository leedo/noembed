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

sub build_url {
  my ($self, $req) = @_;

  my $res = Noembed::Util->http_get($req->url);

  if ($res->code == 200) {
    my $video = $self->{scraper}->scrape($res->decoded_content);
    my $uri = URI->new("https://www.youtube.com/oembed/");
    $uri->query_param("url", "https://www.youtube.com/watch?v=$video->{video}{youtubeID}");
    return $uri;
  }

  return $req->url;
}

1;
