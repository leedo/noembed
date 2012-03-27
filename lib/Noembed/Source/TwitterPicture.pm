package Noembed::Source::TwitterPicture;

use parent 'Noembed::ImageSource';
use Noembed::Util;
use JSON;

sub prepare_source {
  my $self = shift;
  $self->{tweet_api} = "http://api.twitter.com/1/statuses/show/%s.json?include_entities=true";
  $self->{tweet_re} = qr{https?://(?:www\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)};
}

sub provider_name { "Twitter" }
sub patterns {
  'https?://pic\.twitter\.com/.+',
  'https?://(?:www\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)/photo/\d+/?$',
}

sub pre_download {
  my ($self, $req, $cb) = @_;
  Noembed::Util::http_resolve $req->url, sub {
    my $tco = shift;
    Noembed::Util::http_resolve $tco, sub {
      my $tweet_url = shift;
      my ($id) = $tweet_url =~ $self->{tweet_re};
      $req->content_url(sprintf $self->{tweet_api}, $id);
      $cb->($req);
    }
  };
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
