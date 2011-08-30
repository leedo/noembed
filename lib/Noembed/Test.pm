package Noembed::Test;

use Carp;
use HTTP::Request;
use Test::More;
use Plack::Test;
use JSON;

use base Exporter::;
@EXPORT = ("test_embed");

sub test_embed {
  my %args = @_;

  my $app    = delete $args{app} or croak "app is required";
  my $url    = delete $args{url} or croak "url is required";
  my $output = delete $args{output} or croak "output is required";

  test_psgi
    app => $app,
    client =>  sub {
      my $cb = shift;
      my $req = HTTP::Request->new(GET => "/embed?url=$url");
      my $res = $cb->($req);
      my $input = decode_json $res->content;
      is_deeply $input, $output, $url;
    };
}

1;
