package Noembed::Source::YouTube;

use JSON;
use parent 'Noembed::Source';

my $re = qr{^http://[^\.]+\.youtube\.com/watch\?v=(.+)}i;

sub request_url {
  my ($self, $req) = @_;
  my $url = $req->parameters->{url};
  return "http://www.youtube.com/oembed/?url=$url";
}

sub matches {
  my ($self, $url) = @_;
  return $url =~ $re;
}

sub filter {
  my ($self, $body) = @_;
  my $data = decode_json $body;
  my ($id) = $data->{html} =~ m{/v/([^\?]+)?};

  my $width = $data->{width} || 640;
  my $height = $data->{height} || 385;

  $data->{html} = "<iframe type='text/html' width='$width' height='$height'"
                . " src='http://www.youtube.com/embed/$id' frameborder=0></iframe>";
  return $data;
}
