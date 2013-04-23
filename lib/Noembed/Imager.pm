package Noembed::Imager;

use Imager;

sub dimensions {
  my $data = shift;
  my ($width, $height);
  eval {
    my $image = Imager->new(data => $data);
    $width = $image->getwidth;
    $height = $image->getheight;
  };
  return ($width, $height);
}

1;
