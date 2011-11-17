package Noembed::Source::YouTube;

use JSON;
use URI;
use URI::QueryParam;

use parent 'Noembed::Source';

sub patterns {
  'https?://(?:[^\.]+\.)?youtube\.com/watch/?\?(?:.+&)?v=([^&]+)',
  'https?://youtu\.be/([a-zA-Z0-9_-]+)'
}
sub provider_name { "YouTube" }

sub request_url {
  my ($self, $req) = @_;
  my $uri = URI->new("http://www.youtube.com/oembed/");

  my $id = $req->captures->[0];
  $uri->query_param("url", "http://www.youtube.com/watch?v=$id");

  if ($req->maxwidth) {
    $uri->query_param("maxwidth", $req->maxwidth);
  }

  if ($req->maxheight) {
    $uri->query_param("maxheight", $req->maxheight);
  }

  return $uri->as_string;
}

sub serialize {
  my ($self, $body, $req) = @_;

  my $data = from_json $body;
  my ($url) = $data->{html} =~ m{src="([^"]+)"};

  # tack on start parameter if timecode was in original URL
  if (my @t = $req->url =~ /[#\?]a?t=(?:(\d+)m)?(\d+)s/) {
    my $seconds = pop @t;
    if (@t) {
      $seconds += $t[0] * 60;
    }
    $url .= "&start=$seconds";
  }

  $data->{html} = $self->render($data, $url);
  return $data;
}

1;
