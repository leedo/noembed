package Noembed::Source::GiantBomb;

use JSON;
use HTML::Entities;
use Web::Scraper;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process "div.player", video => sub {
      my $el = shift;
      my $data = from_json decode_entities $el->attr("data-video");
      return {
        src => $data->{urls}{progressive_high},
        title => $data->{video_name},
      };
    };
  };
}

sub provider_name { "GiantBomb" }
sub patterns { 'https?://www\.giantbomb\.com/([^/]+)/\d+-\d+/?' }

sub serialize {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);
  
  die "not a video" unless $data and $data->{video};

  return +{
    title => $data->{video}{title},
    html  => $self->render($data->{video}),
  }
}

1;
