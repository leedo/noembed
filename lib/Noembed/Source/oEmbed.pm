package Noembed::Source::oEmbed;

use Web::oEmbed;
use JSON;
use parent 'Noembed::Source';

our $DEFAULT = [
  ['http://*.youtube.com/*', 'http://www.youtube.com/oembed/'],
  ['http://*.flickr.com/*', 'http://www.flickr.com/services/oembed/'],
  ['http://*viddler.com/*', 'http://lab.viddler.com/services/oembed/'],
  ['http://qik.com/video/*', 'http://qik.com/api/oembed.{format}'],
  ['http://www.hulu.com/watch/*', 'http://www.hulu.com/api/oembed.{format}'],
];

sub prepare_source {
  my $self = shift;

  my $oembed = Web::oEmbed->new;
  my $sources = $DEFAULT;

  for my $source (@$sources) {
    $oembed->register_provider({
      url => $source->[0],
      api => $source->[1],
    });
  }

  $self->{oembed} = $oembed;
}

sub filter {
  my ($self, $body) = @_;
  my $data = decode_json $body;

  if (!$data->{html}) {
    $data->{html} = "<a href='$data->{url}'>";

    if ($data->{type} eq "photo") {
      $data->{html} .= "<img src='$data->{url}'>";
    }
    else {
      $data->{html} .= ($data->{title} || $data->{url});
    }
    $data->{html} .= "</a>";
  }

  return $data;
}

sub matches {
  my ($self, $url) = @_;
  !!$self->{oembed}->provider_for($url);
}

sub request_url {
  my ($self, $url, $params) = @_;
  $self->{oembed}->request_url($url);
}

1;
