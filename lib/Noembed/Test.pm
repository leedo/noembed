package Noembed::Test;

use Carp;
use Test::More;
use Test::Fatal;
use URI::Escape;
use HTTP::Message::PSGI;
use HTTP::Request;
use Noembed;
use JSON;

use base Exporter::;
@EXPORT = ("test_embed");

sub test_embed {
  my %args = @_;

  my $noembed = Noembed->new;
  $noembed->prepare_app;

  my $url     = delete $args{url} or croak "url is required";
  my $output  = delete $args{output} or croak "output is required";

  my $env = HTTP::Request->new(GET => "/embed?url=".uri_escape($url))->to_psgi;
  my $req = Noembed::Request->new($env);

  my $cv = AE::cv;

  $noembed->add_lock($req, sub {
    my $res = shift;
    is $res->[0], 200, "status $url";

    my $data = decode_json $res->[2][0];

    is(
      exception { die $data->{error} if $data->{error}},
      undef,
      "no error $url",
    );

    is_deeply $data, $output, $url;

    $cv->send;
  });

  $noembed->handle_url($req);
  $cv->recv;
}

1;
