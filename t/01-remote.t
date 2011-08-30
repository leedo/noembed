use Test::More;
use Noembed::Test;
use Noembed;
use JSON;

my $app = Noembed->new;

for (glob 't/data/*.t') {
  open(my $fh, '<', $_) or die $!;
  my ($url, @body) = <$fh>;
  test_embed 
    app => $app,
    url => $url,
    output => decode_json(join "", @body),
}

done_testing;
