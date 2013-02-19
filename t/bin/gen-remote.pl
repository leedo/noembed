#!/usr/bin/env perl

use strict;
use warnings;

use Noembed;
use Noembed::Util;
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
  my $cb = pop;
  my $url = shift;
  my $hash = sha1_hex $url;

  $orig->($url, @_, sub {
    my ($body, $headers) = @_;
    open my $fh, ">", "t/data/requests/$hash";
    print $fh encode_json [ $body, $headers ];
    $cb->($body, $headers)
  });
};

local $ENV{PLACK_SERVER} = 'Twiggy';
local $Plack::Test::Impl = 'Server';

my $app = Noembed->new->to_app;

test_psgi $app, sub {
  my $cb = shift;

  for my $url (@urls) {
    print "generating test - $url\n";

    my $res = $cb->(GET "/?url=" . uri_escape($url));

    next unless $res->code == 200;

    my $data = decode_json $res->content;
    my $provider = lc $data->{provider_name};
    $provider =~ s/ /_/g;

    open my $test, ">:utf8", "t/data/$provider.t";
    print $test $url, "\n", $res->content;
  }
};

__DATA__

