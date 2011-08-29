package Noembed::Source::GiantBomb;

use JSON;
use HTML::Entities;
use Web::Scraper;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{url_re} = qr{https?://www\.giantbomb\.com/([^/]+)/\d+-\d+}i;
  $self->{scraper} = scraper {
    process "div.player", video => sub {
      my $el = shift;
      my $data = decode_json decode_entities $el->attr("data-video");
      return {
        src => $data->{urls}{progressive_high},
        title => $data->{video_name},
      };
    };
  };
}

sub provider_name { "GiantBomb" }

sub matches {
  my ($self, $url) = @_;
  $url =~ $self->{url_re};
}

sub filter {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);
  return +{
    title => $data->{video}{title},
    html  => $self->render($data->{video}),
  }
}

1;
