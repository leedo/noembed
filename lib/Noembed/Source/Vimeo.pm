package Noembed::Source::Vimeo;

use JSON;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{re} = qr{http://(?:www\.)?vimeo\.com/.+}i;
}

sub matches {
  my ($self, $url) = @_;
  $url =~ $self->{re};
}

sub request_url {
  my ($self, $req) = @_;
  "http://www.vimeo.com/api/oembed.json?url=".$req->url;
}

sub filter {
  my ($self, $body, $req) = @_;
  my $data = decode_json $body;
  $data->{width}  = $req->width($data->{width} || 640);
  $data->{height} = $req->height($data->{height} || 360);
  $data->{html} =~ s/width="\d+"/width="$data->{width}"/;
  $data->{html} =~ s/height="\d+"/height="$data->{height}"/;
  $data;
}

1;
