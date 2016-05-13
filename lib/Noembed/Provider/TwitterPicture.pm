package Noembed::Provider::TwitterPicture;

use parent 'Noembed::ImageProvider';
use Noembed::Provider::Twitter;
use Noembed::Util;
use JSON;

sub prepare_provider {
  my $self = shift;
  $self->{tweet_api} = "http://api.twitter.com/1.1/statuses/show/%s.json?include_entities=true";
  $self->{credentials} = Noembed::Provider::Twitter::read_credentials($self);
}

sub provider_name { "Twitter" }
sub shorturls { 'https?://pic\.twitter\.com/.+' }
sub patterns {
  'https?://(?:www\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)/photo/\d+(?:/large|/)?$',
}

sub build_url {
  my ($self, $req, $cb) = @_;
  Noembed::Provider::Twitter::oauth_url($self, sprintf($self->{tweet_api}, $req->captures->[0]));
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
