package Noembed::Worker;

use Noembed::Pygmentize;
use Imager;

our $pyg = Noembed::Pygmentize->new;

sub run {
  my @ret = eval { _run(@_) };
  return $@ ? (0, $@) : (1, @ret);
}

sub _run {
  my $job = shift;

  if ($job eq "dimensions") {
    my $image = Imager->new(data => $_[0]);
    return ($image->getwidth, $image->getheight);
  }

  elsif ($job eq "colorize") {
    return $pyg->colorize(@_);
  }

  die "did not recognize job name";
}

1;
