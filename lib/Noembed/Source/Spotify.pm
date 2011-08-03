package Noembed::Source::Spotify;

use HTML::Entities;
use Web::Scraper;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{re} = qr{https?://open\.spotify\.com/track/(\w{22})}i;
  $self->{scraper} = scraper {
    process 'title', title => 'TEXT';
    process '#title', track => 'RAW';
    process '#artist .meta-info', artist => 'RAW';
    process '#album .meta-info', album => 'RAW';
    process '#cover-art', coverart => '@src';
  };
}

sub provider_name { "Spotify" }

sub matches {
  my ($self, $url) = @_;
  $url =~ $self->{url_re};
}

sub filter {
  my ($self, $body) = @_;

  my $data = $self->{scraper}->scrape($body);
  $data->{title} =~ s/ on Spotify//;

  return +{
    title => $data->{title},
    html  => '<div class="spotify-embed">'
           .  '<img class="spotify-image" src="'.$data->{coverart}.'"/>'
           .  '<span class="spotify-title">'.$data->{track}.'</span>'
           .  '<span class="spotify-artist">'.$data->{artist}.'</span> from '
           .  '<span class="spotify-album">'.$data->{album}.'</span>'
           . '</div>'
  }
}

sub style {
  $self->{style} ||= do {
    local $/;
    <DATA>;
  };
}

1;

__DATA__
div.spotify-embed {
  background: #373737;
  color: #999;
  overflow: hidden;
  font-size: 1.2em;
  padding: 10px;
}

div.spotify-embed a {
  color: #B3B3B3;
  text-decoration: underline;
}

div.spotify-embed span.spotify-title {
  font-size: 1.5em;
  display: block;
}
div.spotify-embed span.spotify-title a {
  color: #fff;
  text-decoration: none;
}

div.spotify-embed img {
  float: left;
  margin-right: 10px;
}
