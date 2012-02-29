use Noembed::Test;
use Test::More;
use JSON;

for (glob 't/data/*.t') {
  open(my $fh, '<:utf8', $_) or die $!;
  my ($url, @body) = <$fh>;
  chomp($url);
  test_embed 
    local => 1,
    url => $url,
    output => decode_json(join "", @body),
}

done_testing;
