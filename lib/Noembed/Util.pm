package Noembed::Util;

use Encode;
use AnyEvent::HTTP ();

sub http_resolve {
  my ($url, $cb) = @_;

  Noembed::Util::http_get $url, sub {
    my ($body, $headers) = @_;

    if ($headers->{location}) {
      $url = $headers->{location};
    }
    elsif ($body and $body =~ /URL=([^"]+)"/) {
      $url = $1;
    }

    $cb->($url);
  };
}

sub http_get {
  my ($url, $cb) = @_;

  AnyEvent::HTTP::http_request get => $url, {
        persistent => 0,
        keepalive  => 0,
    },
    sub {
      my ($body, $headers) = @_;

      $body = decode("utf8", $body);
      $cb->($body, $headers);
    };
}

1;
