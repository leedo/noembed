use Test::More;
use Noembed::Test;
use Noembed;

my $app = Noembed->new;

for (glob 't/data/*.t') {
  open(my $fh, '<', $_) or die $!;
  my ($url, @body) = <$fh>;
  test_embed 
    app => $app,
    url => $url,
    output => join "", @body
}

done_testing;
