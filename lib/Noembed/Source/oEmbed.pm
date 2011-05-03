package Noembed::Source::oEmbed;

use Web::oEmbed;
use parent 'Noembed::Source';

our $DEFAULT = [
  ['http://*.youtube.com/*', 'http://www.youtube.com/oembed/'],
  ['http://*.flickr.com/*', 'http://www.flickr.com/services/oembed/'],
  ['http://*viddler.com/*', 'http://lab.viddler.com/services/oembed/'],
  ['http://qik.com/video/*', 'http://qik.com/api/oembed.{format}'],
  ['http://www.hulu.com/watch/*', 'http://www.hulu.com/api/oembed.{format}'],
  ['http://www.vimeo.com/*', 'http://www.vimeo.com/api/oembed.{format}'],
];

sub new {
  my ($class, %args) = @_;

  my $oembed = Web::oEmbed->new;
  my $sources = $args{sources} || $DEFAULT;

  for my $source (@$sources) {
    $oembed->register_provider({
      url => $source->[0],
      api => $source->[1],
    });
  }

  bless {oembed => $oembed}, $class;
}

sub matches {
  my ($self, $url) = @_;
  !!$self->{oembed}->provider_for($url);
}

sub request_url {
  my ($self, $url) = @_;
  my $service = $self->{oembed}->request_url($url);
  return $service;
}

1;
