package Noembed::Source::YouTube;

use JSON;
use URI;
use URI::QueryParam;

use parent 'Noembed::Source';

sub patterns {
  'https?://(?:[^\.]+\.)?youtube\.com/watch/?\?(?:.+&)?v=(.+)',
  'https?://youtu.be/([a-zA-Z0-9_]+)'
}
sub provider_name { "YouTube" }

sub request_url {
  my ($self, $req) = @_;
  my $uri = URI->new("http://www.youtube.com/oembed/");

  my ($id) = $req->captures;
  $uri->query_param("url", "http://www.youtube.com/watch?v=$id");

  if ($req->maxwidth) {
    $uri->query_param("maxwidth", $req->maxwidth);
  }

  if ($req->maxheight) {
    $uri->query_param("maxheight", $req->maxheight);
  }

  return $uri->as_string;
}

sub filter {
  my ($self, $body, $req) = @_;

  my $data = decode_json $body;
  my ($id) = $data->{html} =~ m{/v/([^\?]+)?};

  # tack on start parameter if timecode was in original URL
  if (my @t = $req->url =~ /[#\?]a?t=(?:(\d+)m)?(\d+)s/) {
    my $seconds = pop @t;
    if (@t) {
      $seconds += $t[0] * 60;
    }
    $id .= "?start=$seconds";
  }

  $data->{html} = "<iframe type='text/html' width='$data->{width}' height='$data->{height}'"
                . " src='https://www.youtube.com/embed/$id' frameborder=0></iframe>";
  return $data;
}

1;
