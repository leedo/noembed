package Noembed::oEmbedSource;

use URI;
use URI::QueryParam;
use JSON;
use Carp;
use parent 'Noembed::Source';

sub options { qw/maxwidth maxheight/ };

sub serialize {
  my ($self, $body, $req) = @_;
  my $data = from_json $body;

  if (!$data->{html}) {
    $data->{html} = $self->render($data, $req->url);
  }

  delete $data->{url};
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
  my $uri = URI->new($self->oembed_url);
  $uri->query_param("url", $req->url);
  $uri->query_param("format", "json");
  return $uri;
}

1;

=pod

=head1 NAME

Noembed::oEmbedSource - a base class for sites with existing oEmbed support

=head1 DESCRIPTION

This is the simplest of source base classes. It is meant for sites that already have
oEmbed support. For sites like this we can simply proxy requests to their oEmbed
endpoint. For this reason this base class only needs to have C<oembed_url> defined.

=head1 METHODS

=over 4

=item oembed_url

Must return a string with the site's oEmbed endpoint. e.g. C<http://soundcloud.com/oembed>

=back

=head1 SEE ALSO

L<Noembed::Source::SoundCloud>, L<Noembed::Source::Flickr>, L<Noembed::Source::Hulu>,
L<Noembed::Source::Qik>, L<Noembed::Source::SlideShare>, L<Noembed::Source::Viddler>

=cut
