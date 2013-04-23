package Noembed::Worker;

use Noembed::Pygmentize;
use Imager;

our $pyg = Noembed::Pygmentize->new;

sub run {
  my $job = shift;

  if ($job eq "dimensions") {
    my ($width, $height);
    eval {
      my $image = Imager->new(data => $data);
      $width = $image->getwidth;
      $height = $image->getheight;
    };
    return ($width, $height);
  }

  elsif ($job eq "colorize") {
    return $pyg->colorize(@_);
  }

  die "did not recognize job name";
}

1;
