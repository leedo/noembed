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
  my ($self, $url, $params) = @_;
  "http://www.vimeo.com/api/oembed.json?url=$url";
}

sub filter {
  my ($self, $body) = @_;
  my $data = decode_json $body;
  $data->{html} =~ s/width="\d+"/width="640"/;
  $data->{html} =~ s/height="\d+"/height="360"/;
  $data;
}

1;
