package Noembed::Source::GiantBomb;

use JSON;
use HTML::Entities;
use Web::Scraper;
use AnyEvent::HTTP;

use parent 'Noembed::Source::YouTube';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process "div.player", video => sub {
      my $el = shift;
      from_json decode_entities $el->attr("data-video");
    };
  };
}

sub provider_name { "GiantBomb" }
sub patterns { 'https?://www\.giantbomb\.com/([^/]+)/\d+-\d+/?' }

sub pre_download {
  my ($self, $req, $cb) = @_;

  http_request get => $req->url, {
        persistent => 0,
        keepalive  => 0,
    },
    sub {
      my ($body, $headers) = @_;
      if ($headers->{Status} == 200) {
        my $video = $self->{scraper}->scrape($body);
        my ($hash) = $req->url =~ /(#.+)$/;
        $req->pattern(qr{v=([^&]+)});
        $req->url("http://www.youtube.com/watch?v=$video->{video}{youtube_id}$hash");
      }
      $cb->($req);
    };
}

1;
