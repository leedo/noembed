package Noembed::ImageSource;

use parent 'Noembed::Source';

sub post_download {
  my ($self, $body, $req, $cb) = @_;

  my $data = $self->image_data($body, $req);
  die "No image found" unless $data->{src};

  my $maxw = $req->parameters->{maxwidth} || 0;
  my $maxh = $req->parameters->{maxheight} || 0;

  my $prefix = join "/", "https://noembed.com/i", $maxw, $maxh;
  $data->{src} = "$prefix/$data->{src}";

  $req->dimensions($data->{src}, sub {
    my ($w, $h) = @_;
    $data->{width} = $w;
    $data->{height} = $h;
    $cb->($data);
  });
}

sub serialize {
  my ($self, $data, $req) = @_;

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

sub finalize {
  my ($self, $body, $req) = @_;

  return +{
    title => $req->url,
    provider_name => $self->provider_name,
    url => $req->url,
    type  => "rich",
    # overrides the above properties
    %{ $self->serialize($body, $req) },
  };
}

sub filename {
  my ($self, $ext) = @_;
  if ($ext eq "html") {
    return "ImageSource.html";
  }
  return $self->SUPER::filename($ext);
}

1;

=pod

=head1 NAME

Noembed::ImageSource - a base class for image sources

=head1 DESCRIPTION

This is a subclass of L<Noembed::Source> meant for images. User's
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

L<Noembed::Source::Instagram>, L<Noembed::Source::Imgur>,
L<Noembed::Source::Skitch>

=cut
