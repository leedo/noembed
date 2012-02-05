package Noembed::Source::GiantBomb;

use JSON;
use HTML::Entities;
use Web::Scraper;

use parent 'Noembed::Source::YouTube';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process "div.player", video => sub {
      my $el = shift;
      from_json decode_entities $el->attr("data-video");
    };
  };
  $self->{youtube_re} = qr{https?://(?:[^\.]+\.)?youtube\.com/watch/?\?(?:.+&)?v=(.+)};
}

sub provider_name { "GiantBomb" }
sub patterns { 'https?://www\.giantbomb\.com/([^/]+)/\d+-\d+/?' }

sub pre_download {
  my ($self, $req, $cb) = @_;

  Noembed::Util::http_get $req->url, sub {
    my ($body, $headers) = @_;
    if ($headers->{Status} == 200) {
      my $video = $self->{scraper}->scrape($body);
      my ($hash) = $req->url =~ /(#.+)$/;
      $req->pattern($self->{youtube_re});
      $req->url("http://www.youtube.com/watch?v=$video->{video}{youtube_id}$hash");
    }
    $cb->($req);
  };
}

1;
