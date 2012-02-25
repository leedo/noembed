package Noembed::Request;

use parent 'Plack::Request';

use Digest::SHA1;
use Noembed::Util;

sub new {
  my ($class, $env) = @_;
  my $self = $class->SUPER::new($env);
  $self->{hash} = Digest::SHA1::sha1_hex(lc $env->{QUERY_STRING});
  return $self;
}

sub hash {
  my $self = shift;
  return $self->{hash};
}

sub url {
  my ($self, $url) = @_;
  if (defined $url) {
    $self->parameters->{url} = $url;
  }
  return $self->parameters->{url};
}

sub content_url {
  my ($self, $url) = @_;

  if (defined $url) {
    $self->{content_url} = $url;
  }
  if ($self->{content_url}) {
    return $self->{content_url};
  }

  return $self->url;
}

sub captures {
  my $self = shift;
  my @captures;

  if ($self->{pattern}) {
    @captures = ($self->url =~ $self->{pattern});
  }

  return \@captures;
}

sub pattern {
  my ($self, $pattern) = @_;
  if (defined $pattern) {
    $self->{pattern} = $pattern;
  }
  $self->{pattern};
}

sub error {
  my ($self, $message) = @_;

  Noembed::Util::json_res {
    error => ($message || "unknown error"),
    url   => $self->url,
  }, 'Cache-Control', 'no-cache';
}

1;

=pod

=head1 NAME

Noembed::Request - a client embed request

=head1 DESCRIPTION

This class represents a client embed request. See L<Plack::Request>
for details on most methods.

=head1 ADDITIONAL METHODS

=over 4

=item hash

A SHA1 hash representing the requested embed.

=item url

The URL that the client requested for embedding. This should not
change throughout the response.

=item content_url ($url)

The URL that Noembed will download. Typically, you will not need to change
this. It is populated by a source's C<build_url> method. However, it can be 
used in a C<pre_download> hook to modify the URL will be downloaded.

=item pattern

If the requested URL matched any of the loaded L<Sources> this will return
the compiled regular expression that it matched.

=item captures

Returns an array reference with any captures from the matched C<pattern>.

=back

=cut
