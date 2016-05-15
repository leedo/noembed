package Noembed::Test;

use lib "t/lib";

use Carp;
use Test::More;
use Test::Fatal;
use URI::Escape;
use HTTP::Message::PSGI;
use HTTP::Request;
use Digest::SHA1 qw/sha1_hex/;
use Noembed::Config;
use Noembed::App;
use JSON;

use base Exporter::;
@EXPORT = ("test_embed");

sub test_embed {
  my %args = @_;

  my $config = Noembed::Config->new("config.json");
  my $noembed = Noembed::App->new($config);

  my $url      = delete $args{url} or croak "url is required";
  my $callback = delete $args{callback};
  my $output   = delete $args{output};

  local *Noembed::Util::http_get = \&_local_http_get if $args{local};

  my $env = HTTP::Request->new(GET => "/embed?url=".uri_escape($url))->to_psgi;

  my $req = Noembed::Request->new($env);
  my $res = $noembed->handle_request($req);

  my $data = decode_json $res->[2][0];

  if ($callback) {
    $callback->($data);
  }
  else {
    subtest $url => sub {
      is $res->[0], 200, "200 status";
      is $data->{error}, undef, "no error";
      is_deeply $data, $output, "response matches";
    };
  }
}

sub _local_http_get {
  my ($class, $url) = @_;
  my $hash = sha1_hex $url;

  unless (-e "t/data/requests/$hash") {
    return HTTP::Response->new(
      404, "no local copy of this request! use t/bin/gen-tests.pl"
    );
  }

  open my $fh, "<", "t/data/requests/$hash";
  local $/;
  my $body = <$fh>;
  my $body = decode_json $body;

  return HTTP::Response->new(200, $body);
}

1;
