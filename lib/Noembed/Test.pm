package Noembed::Test;

use Carp;
use Test::More;
use Test::Fatal;
use URI::Escape;
use HTTP::Message::PSGI;
use HTTP::Request;
use Digest::SHA1 qw/sha1_hex/;
use Noembed;
use JSON;

use base Exporter::;
@EXPORT = ("test_embed");

sub test_embed {
  my %args = @_;

  my $noembed = Noembed->new;
  $noembed->prepare_app;

  my $url    = delete $args{url} or croak "url is required";
  my $output = delete $args{output} or croak "output is required";

  local *Noembed::Util::http_get = \&_local_http_get if $args{local};

  my $env = HTTP::Request->new(GET => "/embed?url=".uri_escape($url))->to_psgi;
  my $cv = AE::cv;

  my $respond = sub {
    my $res = shift;
    my $data = decode_json $res->[2][0];

    subtest $url => sub {
      is $res->[0], 200, "200 status";
      is $data->{error}, undef, "no error";
      is_deeply $data, $output, "response matches";
    };

    $cv->send;
  };

  my $req = Noembed::Request->new($env, $respond);

  $noembed->handle_url($req);
  $cv->recv;
}

sub _local_http_get {
  my $cb = pop;
  my $url = shift;
  my $hash = sha1_hex $url;

  unless (-e "t/data/requests/$hash") {
    die "no local copy of this request! use t/bin/gen-tests.pl";
  }

  open my $fh, "<", "t/data/requests/$hash";
  local $/;
  my $body = <$fh>;
  my $res = decode_json $body;
  $cb->(@$res);
}

1;
