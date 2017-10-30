package Noembed::Provider::HookTube;

use JSON;
use URI;
use URI::QueryParam;

use parent 'Noembed::Provider';

sub patterns {
  'https?://(?:[^\.]+\.)?hooktube\.com/watch/?\?(?:.+&)?v=([^&]+)',
  'https?://(?:[^\.]+\.)?hooktube\.com/embed/([a-zA-Z0-9_-]+)'
}
sub provider_name { "HookTube" }
sub options { qw/maxwidth maxheight autoplay/}

sub build_url {
  my ($self, $req) = @_;
  my $uri = URI->new("http://www.hooktube.com/oembed/");

  my $id = $req->captures->[0];
  $uri->query_param("url", "http://www.hooktube.com/watch?v=$id");
  $uri->query_param("scheme", "https");

  return $uri;
}

sub serialize {
  my ($self, $body, $req) = @_;

  my $data = from_json $body;
  my ($src) = $data->{html} =~ m{src="([^"]+)"};
  my $uri = URI->new($src);

  # tack on start parameter if timecode was in original URL
  if (my @t = $req->url =~ /[&#?]a?t=(?:(\d+)m)?(\d+)s?/) {
    my $seconds = pop @t;
    if (@t) {
      $seconds += $t[0] * 60;
    }
    $data->{title} = "$data->{title} (skip to ".$seconds."s)";
    $uri->query_param(start => $seconds);
  }

  if (my $autoplay = $req->param("autoplay")) {
    $uri->query_param(autoplay => $autoplay);
  }

  $data->{html} = $self->render($data, $uri->as_string);
  return $data;
}

1;
