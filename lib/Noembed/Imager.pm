package Noembed::Imager;

use AnyEvent::Worker;
use Imager;

sub new {
  my ($class, %args) = @_;
  bless {}, $class; 
}

sub worker {
  my $self = shift;
  $self->{worker} ||= AnyEvent::Worker->new(sub {
    my $data = shift;
    my ($width, $height);
    eval {
      my $image = Imager->new(data => $data);
      $width = $image->getwidth;
      $height = $image->getheight;
    };
    return ($width, $height);
  });
}

sub dimensions {
  my ($self, $image, $cb) = @_;
  $self->worker->do($image, sub {
    my ($worker, $w, $h) = @_;
    $cb->($w, $h)
  });
}

1;
