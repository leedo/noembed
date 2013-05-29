package Noembed::Provider::TwitterPicture;

use parent 'Noembed::ImageProvider';
use Noembed::Provider::Twitter;
use Noembed::Util;
use JSON;

sub prepare_provider {
  my $self = shift;
  $self->{tweet_api} = "http://api.twitter.com/1.1/statuses/show/%s.json?include_entities=true";
  $self->{tweet_re} = qr{https?://(?:www\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)};
  $self->{credentials} = Noembed::Provider::Twitter::read_credentials();
}

sub provider_name { "Twitter" }
sub shorturls { 'https?://pic\.twitter\.com/.+' }
sub patterns {
  'https?://(?:www\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)/photo/\d+(?:/large|/)?$',
}

sub pre_download {
  my ($self, $req, $cb) = @_;
  $req->http_resolve($req->url, sub {
    my $tco = shift;
    $req->http_resolve($tco, sub {
      my $tweet_url = shift;
      my ($id) = $tweet_url =~ $self->{tweet_re};
      my $url = Noembed::Provider::Twitter::oauth_url($self, sprintf($self->{tweet_api}, $id));
      $req->content_url($url);
      $cb->($req);
    });
  });
}

sub image_data {
  my ($self, $body) = @_;
  my $tweet = decode_json $body;
  if ($tweet->{entities}{media}) {
    my @images = grep {$_->{type} eq "photo"} @{$tweet->{entities}{media}};
    if (@images) {
      return {
        src => $images[0]->{media_url_https},
        title => $tweet->{text},
      }
    }
  }
  die "no images";
}

1;
