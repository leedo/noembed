package Noembed::Request;

use parent 'Plack::Request';

use Digest::SHA1;

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

1;
