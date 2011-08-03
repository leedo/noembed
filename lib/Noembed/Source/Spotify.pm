package Noembed::Source::Spotify;

use HTML::Entities;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{url_re} = qr{https?://open\.spotify\.com/track/(\w{22})}i;
  $self->{title_re} = qr{<title>(.*?) on Spotify</title>};
  $self->{spotify_re} = qr{<meta property="og:audio" content="spotify:track:(\w{22})"};
}

sub provider_name { "Spotify" }

sub matches {
  my ($self, $url) = @_;
  $url =~ $self->{url_re};
}

sub filter {
  my ($self, $body) = @_;
  my ($title) = $body =~ $self->{title_re};
  my ($spotify_link) = $body =~ $self->{spotify_re};

  return +{
    title => $title,
    html => "<a href=\"spotify:track:$spotify_link\">$title</a>",
  }
}

1;
