package Noembed::Source::Twitter;

use JSON;
use Text::MicroTemplate qw/encoded_string/;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{url_re} = qr{(http://t\.co/[0-9a-zA-Z]+)};
}

sub patterns { 'https?://(?:www\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)' }
sub provider_name { "Twitter" }

sub request_url {
  my ($self, $req) = @_;
  my $id = $req->captures->[0];
  return "http://api.twitter.com/1/statuses/show/$id.json";
}

sub post_download {
  my ($self, $body, $cb) = @_;

  my $tweet = decode_json $body;
  my @urls = $tweet->{text} =~ /$self->{url_re}/g; 
  return $cb->($tweet) unless @urls;
  my $cv = AE::cv;

  while (my $url = shift @urls) {
    $cv->begin;
    Noembed::http_resolve $url, sub {
      my $resolved = shift;
      $tweet->{text} =~ s/\Q$url\E/$resolved/;
      $cv->end;
    };
  }

  $cv->cb(sub {$cb->($tweet)});
}

sub serialize {
  my ($self, $tweet) = @_;

  $tweet->{$_} = encoded_string $tweet->{$_} for qw/source text/;

  return +{
    title => "Tweet by $tweet->{user}{name}",
    html  => $self->render($tweet),
  };
}

1;
