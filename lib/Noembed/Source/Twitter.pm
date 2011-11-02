package Noembed::Source::Twitter;

use JSON;
use Text::MicroTemplate qw/encoded_string/;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{url_re} = qr{(http://t\.co/[0-9a-zA-Z]+)};
  $self->{name_re} = qr{(?:^|\W)(@[^\s:]+)};
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
  my $tweet = from_json $body;

  my @names = $tweet->{text} =~ /$self->{name_re}/g;
  for my $name (@names) {
    $tweet->{text} =~ s{\Q$name\E}{<a target="_blank" href="http://twitter.com/$name">$name</a>};
  }

  my @urls = $tweet->{text} =~ /$self->{url_re}/g; 
  return $cb->($tweet) unless @urls;

  my $cv = AE::cv;

  for my $url (@urls) {
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
