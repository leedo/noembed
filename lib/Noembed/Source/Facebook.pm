package Noembed::Source::Facebook;

use parent 'Noembed::Source';

use Noembed::Util;
use JSON;

sub provider_name { "Facebook" }
sub patterns { 'https?://www\.facebook\.com/([^/]+)/posts/(\d+)' }

sub pre_download {
  my ($self, $req, $cb) = @_;
  my $profile = "https://graph.facebook.com/".$req->captures->[0];
  $req->http_get($profile, sub {
    my ($body, $headers) = @_;
    my $data = decode_json $body;
    $req->content_url("https://graph.facebook.com/$data->{id}_".$req->captures->[1]);
    $cb->($req);
  });
}

sub serialize {
  my ($self, $body, $req) = @_;
  my $message = decode_json $body;
  return {
    title => "Facebook message by $message->{from}{name}",
    html  => $self->render($message),
  }
}

1;
