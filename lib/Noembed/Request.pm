package Noembed::Request;

use parent 'Plack::Request';

sub new {
  my ($class, $env) = @_;
  my $self = $class->SUPER::new($env);
  $self->{hash} = $env->{REQUEST_URI};
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
