package Noembed::Source::Twitter;

use JSON;
use AnyEvent;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{url_re} = qr{(http://t\.co/[0-9a-zA-Z]+)};
  $self->{name_re} = qr{(?:^|\W)(@[^\s:]+)};
  $self->{tweet_api} = "http://api.twitter.com/1/statuses/show/%s.json?include_entities=true";
}

sub shorturls { 'http://t\.co/[a-zA-Z0-9]' }
sub patterns { 'https?://(?:www\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)' }
sub provider_name { "Twitter" }

sub build_url {
  my ($self, $req) = @_;
  return sprintf $self->{tweet_api}, $req->captures->[0];
}

sub expand_entities {
  my $tweet = shift;

  for my $mention (@{$tweet->{entities}{user_mentions}}) {
    my $name = $mention->{screen_name};
    my $html = "<a target=\"_blank\" href=\"http://twitter.com/$name\">\@$name</a>";
    $tweet->{text} =~ s/@\Q$name\E/$html/;
  }

  for my $url ((@{$tweet->{entities}{urls}}, @{$tweet->{entities}{media}})) {
    my $html = "<a target=\"_blank\" href=\"$url->{expanded_url}\">$url->{display_url}<\/a>";
    $tweet->{text} =~ s/\Q$url->{url}\E/$html/;
  }

  $tweet->{$_} = clean_html($tweet->{$_}) for qw/source text/;
  return $tweet;
}

sub post_download {
  my ($self, $body, $req, $cb) = @_;
  my $tweet = expand_entities from_json $body;
  $self->download_parents($tweet, [], sub {
    $tweet->{parents} = shift;
    $cb->($tweet);
  });
}

sub download_parents {
  my $cb = pop;
  my ($self, $tweet, $parents) = @_;
  my $parent_id = $tweet->{in_reply_to_status_id};
  return $cb->($parents) unless $parent_id;

  my $url = sprintf $self->{tweet_api}, $parent_id;

  Noembed::Util::http_get $url, sub {
    my ($body, $headers) = @_;
    return $cb->($parents) unless $headers->{Status} == 200;;

    my $parent = expand_entities decode_json $body;
    push @$parents, $parent;
    $self->download_parents($parent, $parents, $cb);
  };
}

sub serialize {
  my ($self, $tweet, $req) = @_;

  return +{
    title => "Tweet by $tweet->{user}{name}",
    html  => $self->render($req->hash, $tweet),
  };
}

1;
