#!/usr/bin/env perl

use strict;
use warnings;

use Noembed::Util;
use File::Path qw/make_path/;
use Digest::SHA1 qw/sha1_hex/;
use Plack::Test;
use URI::Escape;
use JSON;
use HTTP::Request::Common;

my @urls = qw{
  http://trailers.apple.com/trailers/independent/rampart/
  http://www.asciiartfarts.com/20060409.html
  http://bash.org/?948884
  http://beeradvocate.com/beer/profile/42/3457
  http://www.flickr.com/photos/lidocaineus/6218766021/
  http://www.hulu.com/watch/331283/saturday-night-live-jay-z-and-beyonces-baby
  http://www.imdb.com/title/tt0032976/
  http://imgur.com/wRBSP
  http://instagr.am/p/n5mWV/
  https://path.com/p/3xnh1s
  https://gist.github.com/syncsynchalt/2985971
  http://gist.github.com/2985971
};

my $orig = \&Noembed::Util::http_get;
local *Noembed::Util::http_get = sub {
  my ($class, $url) = @_;
  my $hash = sha1_hex $url;

  my $res = $orig->($class, $url);
  make_path "t/data/responses/$hash";

  open my $head_fh, ">", "t/data/responses/$hash/head" or die $!;
  print $head_fh encode_json [
    $res->code,
    $res->message,
    [ $res->flatten ],
  ];

  open my $body_fh, ">", "t/data/responses/$hash/body" or die $!;
  binmode($body_fh);
  print $body_fh $res->content;

  return $res;
};

local $ENV{PLACK_SERVER} = 'Twiggy';
local $Plack::Test::Impl = 'Server';

my $app = do "bin/noembed.psgi";

test_psgi $app, sub {
  my $cb = shift;

  for my $url (@urls) {
    print "==\ngenerating test - $url\n";

    my $res = $cb->(GET "/embed?url=" . uri_escape($url));

    if ($res->code != 200) {
      warn $res->status_line;
      next;
    }

    my $data = decode_json $res->content;

    if (defined $data->{error}) {
      warn $data->{error};
      next;
    }

    my $provider = lc $data->{provider_name};
    $provider =~ s/ /_/g;

    open my $test, ">", "t/data/$provider.t";
    binmode($test);
    print $test $url, "\n", $res->content;
  }
};

__DATA__

