package Noembed::Source::Facebook;

use Noembed::Util;
use JSON;
use base 'Noembed::Source';

sub provider_name { "Facebook" }
sub patterns { 'https?://www\.facebook\.com/([^/]+)/posts/(\d+)' }

sub pre_download {
  my ($self, $req, $cb) = @_;
  my $profile = "https://graph.facebook.com/".$req->captures->[0];
  Noembed::Util::http_get $profile, sub {
    my ($body, $headers) = @_;
    my $data = decode_json $body;
    $req->url("https://graph.facebook.com/$data->{id}_".$req->captures->[1]);
    print $req->url."\n";
    $cb->($req);
  };
}

sub serialize {
  my ($self, $body) = @_;
  my $data = decode_json $body;
  return {
    title => "Facebook message by $data->{from}{name}",
    html  => "<p>$data->{message}</p>",
  }
}

1;
