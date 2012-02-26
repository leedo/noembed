package Noembed::Test;

use Carp;
use HTTP::Request;
use Test::More;
use Plack::Test;
use URI::Escape;
use JSON;

use base Exporter::;
@EXPORT = ("test_embed");

sub test_embed {
  my %args = @_;

  local $Plack::Test::Impl = 'Server';
  local $ENV{PLACK_SERVER} = 'Twiggy';

  my $app    = delete $args{app} or croak "app is required";
  my $url    = delete $args{url} or croak "url is required";
  my $output = delete $args{output} or croak "output is required";

  test_psgi
    app => $app,
    client =>  sub {
      my $cb = shift;
      my $req = HTTP::Request->new(GET => "/embed?url=".uri_escape($url));
      my $res = $cb->($req);
      my $input = decode_json $res->content;
      is_deeply $input, $output, $url;
    };
}

1;
