package Noembed::Provider::Twitter;

use JSON;
use AnyEvent;
use Net::OAuth::ProtectedResourceRequest;
use Digest::SHA1;

use parent 'Noembed::Provider';

sub prepare_provider {
  my $self = shift;
  $self->{name_re} = qr{(?:^|\W)(@[^\s:]+)};
  $self->{tweet_api} = "https://api.twitter.com/1.1/statuses/show/%s.json?include_entities=true";
  $self->{credentials} = read_credentials();
}

sub read_credentials {
  my $file = Noembed::share_dir() . "/twitter_cred.json";
  local $/;
  open(my $fh, "<", $file)
    or die "can not read twitter credentials: $file";
  decode_json join "",  <$fh>;
}

sub oauth_url {
  my ($self, $url) = @_;
  my $cred = $self->{credentials};
  local $Net::OAuth::SKIP_UTF8_DOUBLE_ENCODE_CHECK = 1;

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
sub patterns { 'https?://(?:www|mobile\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)/?$' }
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
    $tweet->{text} =~ s/@\Q$name\E/$html/g;
  }

  for my $url ((@{$tweet->{entities}{urls}}, @{$tweet->{entities}{media}})) {
    my $html = "<a target=\"_blank\" href=\"$url->{expanded_url}\">$url->{display_url}<\/a>";
    $tweet->{text} =~ s/\Q$url->{url}\E/$html/g;
  }

  $tweet->{$_} = clean_html($tweet->{$_}) for qw/source text/;
  return $tweet;
}

sub serialize {
  my ($self, $body, $req) = @_;
  my $tweet = expand_entities from_json $body;

  return +{
    title => "Tweet by $tweet->{user}{name}",
    html  => $self->render($req->hash, $tweet),
  };
}

1;
