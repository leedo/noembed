package Noembed::Source::GiantBomb;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{re} = qr{https?://www\.giantbomb\.com/([^/]+)/\d+-\d+}i;
  $self->{video_re} = qr{"progressive_high":[^"]*"([^"]+)"}msi;
  $self->{title_re} = qr{<title>(.*?) - Giant Bomb}msi;
}

sub provider_name { "GiantBomb" }

sub matches {
  my ($self, $url) = @_;
  $url =~ $self->{re};
}

sub filter {
  my ($self, $body ) = @_;
  my ($video) = $body =~ $self->{video_re};
  my ($title) = $body =~ $self->{title_re};
  return +{
    title => $title,
    html  => "<video controls width=640 height=360 src=\"$video\">$title</video>",
  }
}

1;
