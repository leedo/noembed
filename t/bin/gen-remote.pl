#!/usr/bin/env perl

use strict;
use warnings;

use Noembed;
use Plack::Test;
use URI::Escape;
use JSON;
use HTTP::Request::Common;

my $noembed = Noembed->new;

my @urls = qw[
  http://trailers.apple.com/trailers/independent/rampart/
  http://www.asciiartfarts.com/20060409.html
  http://bash.org/?948884
  http://beeradvocate.com/beer/profile/42/3457
  https://www.facebook.com/LessConf/posts/10150577380768167
  http://www.flickr.com/photos/lidocaineus/6218766021/
  http://www.giantbomb.com/quick-look-saints-row-the-third-gangstas-in-space/17-5729/
  http://www.hulu.com/watch/331283/saturday-night-live-jay-z-and-beyonces-baby
  http://www.imdb.com/title/tt0032976/
  http://imgur.com/wRBSP
  http://instagr.am/p/n5mWV/
  https://path.com/p/3xnh1s
  http://picplz.com/user/marcovgl/pic/kwj1l/
  http://rapgenius.com/353465

];

my $app = Noembed->new->to_app;

local $ENV{PLACK_SERVER} = 'Twiggy';
local $Plack::Test::Impl = 'Server';

test_psgi $app, sub {
  my $cb = shift;
  for my $url (@urls) {
    print "requesting $url\n";

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

