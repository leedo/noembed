package Noembed::ImageProvider;

use Noembed::Util;

use parent 'Noembed::Provider';

sub serialize {
  my ($self, $body, $req) = @_;

  my $data = $self->image_data($body, $req);
  die "No image found" unless $data->{src};

  my $maxw = $req->parameters->{maxwidth} || 0;
  my $maxh = $req->parameters->{maxheight} || 0;

  my $prefix = join "/", $self->{image_prefix}, $maxw, $maxh;
  $data->{src} = "$prefix/$data->{src}";

  my ($w, $h) = Noembed::Util->dimensions($data->{src}, $req);
  $data->{width} = $w;
  $data->{height} = $h;

  return +{
    type   => "photo",
    url    => $req->url,
    title  => $data->{title} || $req->url,
    width  => $data->{width},
    height => $data->{height},
    media_url => $data->{src},
    html   => $self->render($data, $req->url),
  };
}

sub rewrite_images {
  my ($self, $html) = @_;
  return $html;
}

sub filename {
  my ($self, $ext) = @_;
  if ($ext eq "html") {
    return "ImageProvider.html";
  }
  return $self->SUPER::filename($ext);
}

1;

=pod

=head1 NAME

Noembed::ImageProvider - a base class for image sources

=head1 DESCRIPTION

This is a subclass of L<Noembed::Provider> meant for images. User's
of this base class should not define a C<serialize> method, but
instead define an C<image_data> method.

This class will automatically check for C<maxheight> and C<maxwidth>
parameters in the request. If found, the image will be scaled down
to fit the requested dimensions.

=head1 METHODS

=over 4

=item image_data ($body)

Receives the downloaded content and must return a hashref containing
C<src> and C<title> keys. These will be used to build the final
HTML for the response.

=back

=head1 SEE ALSO

L<Noembed::Provider::Instagram>, L<Noembed::Provider::Imgur>,
L<Noembed::Provider::Skitch>

=cut
