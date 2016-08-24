package Noembed::Request;

use Digest::SHA1;

use parent 'Plack::Request';

sub new {
  my ($class, $env, $callback) = @_;
  my $self = $class->SUPER::new($env);
  $self->{hash} = Digest::SHA1::sha1_hex(lc $env->{QUERY_STRING});

  return $self;
}


sub url {
  my ($self, $url) = @_;
  if (defined $url) {
    $self->parameters->{url} = $url;
  }
  return $self->parameters->{url};
}

sub pattern {
  my ($self, $pattern) = @_;
  if (defined $pattern) {
    $self->{pattern} = $pattern;
  }
  $self->{pattern};
}

sub hash {
  my $self = shift;
  return $self->{hash};
}

sub captures {
  my $self = shift;
  my @captures;

  if ($self->{pattern}) {
    @captures = ($self->url =~ $self->{pattern});
  }

  return \@captures;
}

1;
