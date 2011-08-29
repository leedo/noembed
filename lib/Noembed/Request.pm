package Noembed::Request;

use parent 'Plack::Request';

sub url {
  my $self = shift;
  $self->parameters->{url};
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
