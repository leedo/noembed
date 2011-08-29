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

sub width {
  my ($self, $width) = @_;
  if ($width) {
    if ($self->maxwidth) {
      return ($self->maxwidth < $width ? $self->maxwidth : $width);
    }
    return $width;
  }
}

sub maxheight {
  my $self = shift;
  $self->parameters->{maxheight};
}

sub height {
  my ($self, $height) = @_;
  if ($height) {
    if ($self->maxheight) {
      return ($self->maxheight < $height ? $self->maxheight : $height);
    }
    return $height;
  }
}

1;
