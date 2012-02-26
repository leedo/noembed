use Test::More;
use Noembed::Test;
use Noembed;
use JSON;

$ENV{PLACK_SERVER} = 'Standalone';
my $app = Noembed->new;

for (glob 't/data/*.t') {
  open(my $fh, '<:utf8', $_) or die $!;
  my ($url, @body) = <$fh>;
  chomp($url);
  test_embed 
    app => $app,
    url => $url,
    output => decode_json(join "", @body),
}

done_testing;
