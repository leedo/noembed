package Noembed::Source::Twitter;

use JSON;
use AnyEvent;
use Net::OAuth::ProtectedResourceRequest;
use Digest::SHA1;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{name_re} = qr{(?:^|\W)(@[^\s:]+)};
  $self->{tweet_api} = "http://api.twitter.com/1/statuses/show/%s.json?include_entities=true";
  $self->{credentials} = $self->read_credentials;
}

sub read_credentials {
  my $self = shift;
  my $file = Noembed::share_dir() . "/twitter_cred.json";
  if (! -r $file) {
    die "can not read twitter credentials: $file";
  }
  local $/;
  open my $fh, "<", $file;
  decode_json join "",  <$fh>;
}

sub oauth_url {
  my ($self, $url) = @_;
  my $cred = $self->{credentials};

  my $req = Net::OAuth::ProtectedResourceRequest->new(
    version => '1.0',
    timestamp => time,
    nonce => Digest::SHA1::sha1_base64(time . $$ . rand),
    signature_method => 'HMAC-SHA1',
    request_url => $url,
    request_method => "GET",  
    extra_params => {include_entities => "true"},
    consumer_key => $cred->{consumer_key},
    consumer_secret => $cred->{consumer_secret},
    token => $cred->{token},
    token_secret => $cred->{token_secret},
  );
  $req->sign;
  return $req->to_url;
}

sub shorturls { 'http://t\.co/[a-zA-Z0-9]+' }
sub patterns { 'https?://(?:www\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)/?$' }
sub provider_name { "Twitter" }

sub build_url {
  my ($self, $req) = @_;
  my $url = sprintf $self->{tweet_api}, $req->captures->[0];
  return $self->oauth_url($url);
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

  my $url = $self->oauth_url(sprintf $self->{tweet_api}, $parent_id);

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
