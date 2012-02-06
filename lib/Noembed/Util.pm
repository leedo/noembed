package Noembed::Util;

use Encode;
use AnyEvent::HTTP ();
use Noembed::Pygmentize;
use Noembed::Imager;

my $pygment = Noembed::Pygmentize->new;
my $imager = Noembed::Imager->new;

sub http_get {
  my ($url, $cb) = @_;

  die "no callback" unless $cb;

  AnyEvent::HTTP::http_request get => $url, {
      persistent => 0,
      keepalive  => 0,
    },
    sub {
      my ($body, $headers) = @_;

      if ($headers->{'content-type'} =~ /^text\//i) {
        $body = decode("utf8", $body);
      }
      $cb->($body, $headers);
    };
}

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

sub dimensions {
  my ($url, $req, $cb) = @_;

  my $maxw = $req->parameters->{maxwidth};
  my $maxh = $req->parameters->{maxheight};

  Noembed::Util::http_get $url, sub {
    my ($body, $headers) = @_;
    if ($headers->{Status} == 200) {
      $imager->dimensions($body, sub {
        my ($w, $h) = @_;

        if ($maxh and $h > $maxh) {
          $w = $w * ($maxh / $h);
          $h = $maxh;
        }
        if ($maxw and $w > $maxw) {
          $h = $h * ($maxw / $w);
          $w = $maxw;
        }

        $cb->(int($w), int($h));
      });
    }
    else {
      $cb->("", "");
    }
  };
}

sub colorize {
  my $cb = pop;
  my ($text, %options) = @_;
  $pygment->colorize($text, %options, $cb);
}

1;
