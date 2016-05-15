use Noembed::Test;
use Test::More;
use JSON;

for (glob 't/data/*.t') {
  open(my $fh, '<', $_) or die $!;
  binmode($fh);
  my $url = <$fh>;
  chomp($url);
  local $/;
  my $body = <$fh>;
  test_embed 
    local => 1,
    url => $url,
    output => decode_json $body,
}

done_testing;
