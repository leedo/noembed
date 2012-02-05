package Noembed::Source::ImgurGallery;

use JSON;

use parent 'Noembed::ImageSource';

sub patterns { 'http://imgur\.com/gallery/[0-9a-zA-Z]+' }
sub provider_name { "Imgur" }

sub build_url {
  my ($self, $req) = @_;
  return $req->url.".json";
}

sub image_data {
  my ($self, $body, $req) = @_;

  my $data = from_json $body;
  my $image = $data->{gallery}{image};

  return {
    src => "http://i.imgur.com/$image->{hash}$image->{ext}",
    title => $image->{title} || $req->url,
  }
}

1;
