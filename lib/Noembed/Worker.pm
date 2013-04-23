package Noembed::Worker;

use Noembed::Pygmentize;
use Noembed::Imager;

our $pyg = Noembed::Pygmentize->new;

sub run {
  my $job = shift;
  if ($job eq "dimensions") {
    return Noembed::Imager::dimensions(@_);
  }
  elsif ($job eq "colorize") {
    return $pyg->colorize(@_);
  }
  die "did not recognize job name";
}

1;
