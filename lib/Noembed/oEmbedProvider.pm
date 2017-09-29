package Noembed::oEmbedProvider;

use URI;
use URI::QueryParam;
use JSON;
use Carp;
use parent 'Noembed::Provider';

sub options { qw/maxwidth maxheight/ };

sub serialize {
  my ($self, $body, $req) = @_;
  my $data = decode_json $body;

  if (!$data->{html}) {
    $data->{html} = $self->render($data, $req->url);
  }

  if ($data->{type} eq "photo") {
    $data->{media_url} = delete $data->{url};
  }

  return $data;
}

sub render {
  my $self = shift;
  $self->{render}->("oEmbed.html", @_);
}

sub provider_name {
  croak "must override provider_name method";
}

sub oembed_url {
  croak "must override oembed_url method";
}

sub build_url {
  my ($self, $req) = @_;
  my $uri = URI->new($self->oembed_url($req));
  $uri->query_param("url", $req->url);
  $uri->query_param("format", "json");
  return $uri;
}

1;

=pod

=head1 NAME

Noembed::oEmbedProvider - a base class for sites with existing oEmbed support

=head1 DESCRIPTION

This is the simplest of base classes. It is meant for sites that
already support oEmbed. For these sites we can simply proxy requests
to their oEmbed endpoint. These classes can skip defining C<serialize>
and C<build_url>, but must define C<oembed_url>.

=head1 METHODS

=over 4

=item oembed_url

Must return a string with the site's oEmbed endpoint. e.g. C<http://soundcloud.com/oembed>

=back

=head1 SEE ALSO

L<Noembed::Provider::SoundCloud>, L<Noembed::Provider::Flickr>, L<Noembed::Provider::Hulu>,
L<Noembed::Provider::Qik>, L<Noembed::Provider::SlideShare>, L<Noembed::Provider::Viddler>,
L<Noembed::Provider::ADN>

=cut
