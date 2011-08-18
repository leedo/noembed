package Noembed::Source::GiantBomb;

use HTML::Entities;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{url_re} = qr{https?://www\.giantbomb\.com/([^/]+)/\d+-\d+}i;
  $self->{attr_re} = qr{data-video="([^"]+)"};
  $self->{video_re} = qr{"progressive_high":[^"]*"([^"]+)"};
  $self->{title_re} = qr{<title>(.*?) - Giant Bomb};
}

sub provider_name { "GiantBomb" }

sub matches {
  my ($self, $url) = @_;
  $url =~ $self->{url_re};
}

sub filter {
  my ($self, $body) = @_;
  my ($title) = $body =~ $self->{title_re};
  my ($attr) = $body =~ $self->{attr_re};
  $attr = decode_entities $attr;
  my ($video) = $attr =~ $self->{video_re};

  return +{
    title => $title,
    html  => "<video preload=\"none\" controls width=\"640\" height=\"360\" src=\"$video\">$title</video>",
  }
}

1;
