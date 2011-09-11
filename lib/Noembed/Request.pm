package Noembed::Request;

use parent 'Plack::Request';

sub url {
  my $self = shift;
  $self->parameters->{url};
}

sub captures {
  my ($self, @captures) = @_;

  if (@captures) {
    $self->{_captures} = \@captures;
    return @captures;
  }

  elsif ($self->{_captures}) {
    return @{ $self->{_captures} };
  }

  return ();
}

sub maxwidth {
  my $self = shift;
  $self->parameters->{maxwidth};
}

sub maxheight {
  my $self = shift;
  $self->parameters->{maxheight};
}

1;
