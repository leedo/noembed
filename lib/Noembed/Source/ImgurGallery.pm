package Noembed::Source::ImgurGallery;

use JSON;

use parent 'Noembed::Source';

sub patterns { 'http://imgur\.com/gallery/[0-9a-zA-Z]+' }
sub provider_name { "Imgur" }

sub build_url {
  my ($self, $req) = @_;
  return $req->url.".json";
}

sub serialize {
  my ($self, $body) = @_;
  my $data = from_json $body;

  my $image = $data->{gallery}{image};
  my $src = "http://i.imgur.com/$image->{hash}$image->{ext}";

  return +{
    html => $self->render($src),
    title => $image->{title} || "No title",
  }
}

1;
